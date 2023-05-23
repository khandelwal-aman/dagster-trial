from dagster import op, job


@op
def add_one(num: int) -> int:
    return num + 1


@op
def add_two(num: int) -> int:
    return num + 2


@op
def subtract(left: int, right: int) -> int:
    return left + right


@job
def sample_job():
    first_result = add_one()  # pylint: disable=no-value-for-parameter
    second_result = add_two(first_result)
    subtract(left=first_result, right=second_result)
