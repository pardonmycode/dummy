import asyncio
import uuid
import time
from typing import Dict, Optional, Any
from enum import Enum


class JobStatus(str, Enum):
    PENDING = "pending"
    RUNNING = "running"
    COMPLETED = "completed"
    FAILED = "failed"


class Job:
    def __init__(self, job_id: str, widget_id: str, user_id: int, params: Dict):
        self.job_id = job_id
        self.widget_id = widget_id
        self.user_id = user_id
        self.params = params
        self.status: JobStatus = JobStatus.PENDING
        self.result: Optional[Dict] = None
        self.error: Optional[str] = None
        self.created_at = time.time()
        self.started_at: Optional[float] = None
        self.completed_at: Optional[float] = None

    def to_dict(self) -> Dict:
        return {
            "job_id": self.job_id,
            "widget_id": self.widget_id,
            "user_id": self.user_id,
            "status": self.status.value,
            "result": self.result,
            "error": self.error,
            "created_at": self.created_at,
            "started_at": self.started_at,
            "completed_at": self.completed_at,
        }


class JobQueue:
    """In-memory job queue using asyncio.Queue for managing AI pipeline execution."""

    def __init__(self, max_concurrent: int = 5):
        self.queue = asyncio.Queue()
        self.jobs: Dict[str, Job] = {}
        self.workers: list = []
        self.max_concurrent = max_concurrent
        self._started = False

    async def start(self):
        """Start the worker pool."""
        if self._started:
            return
        for i in range(self.max_concurrent):
            worker = asyncio.create_task(self._worker(i))
            self.workers.append(worker)
        self._started = True

    async def stop(self):
        """Stop the worker pool."""
        for _ in self.workers:
            await self.queue.put(None)  # Sentinel to stop workers
        for worker in self.workers:
            worker.cancel()
        self.workers.clear()
        self._started = False

    async def submit(self, widget_id: str, user_id: int, params: Dict) -> str:
        """Submit a new job and return its job ID."""
        job_id = str(uuid.uuid4())
        job = Job(job_id, widget_id, user_id, params)
        self.jobs[job_id] = job
        await self.queue.put(job_id)
        return job_id

    async def _worker(self, worker_id: int):
        """Worker loop that processes jobs from the queue."""
        from app.ai.pipeline import run_widget_pipeline
        while True:
            job_id = await self.queue.get()
            if job_id is None:  # Sentinel
                break
            job = self.jobs.get(job_id)
            if not job:
                continue

            job.status = JobStatus.RUNNING
            job.started_at = time.time()
            try:
                job.result = await run_widget_pipeline(
                    job.widget_id,
                    {"user_id": job.user_id},
                    location=job.params.get("location"),
                    force_refresh=job.params.get("force", False),
                )
                job.status = JobStatus.COMPLETED
            except Exception as e:
                job.status = JobStatus.FAILED
                job.error = str(e)
            finally:
                job.completed_at = time.time()
            self.queue.task_done()

    def get_job(self, job_id: str) -> Optional[Job]:
        """Get a job by ID."""
        return self.jobs.get(job_id)

    def get_user_jobs(self, user_id: int, limit: int = 10) -> list:
        """Get recent jobs for a user."""
        user_jobs = [
            j for j in self.jobs.values() if j.user_id == user_id
        ]
        user_jobs.sort(key=lambda j: j.created_at, reverse=True)
        return [j.to_dict() for j in user_jobs[:limit]]

    def queue_size(self) -> int:
        """Return the number of pending jobs."""
        return self.queue.qsize()


# Singleton instance
job_queue = JobQueue(max_concurrent=5)
