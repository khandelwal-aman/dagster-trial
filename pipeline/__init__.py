from dagster import Definitions

from pipeline.sample_job import sample_job
from pipeline.schedules import schedules

defs = Definitions(assets=[], jobs=[sample_job], sensors=[], schedules=schedules)
