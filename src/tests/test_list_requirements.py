from helpers.list_requirements import main
from tests.test_shared import TestHelpers


class TestSettingsBuilderHelper(TestHelpers):
    def test_list_requirements(self):
        assert main([str(self.get_root_folder() / ".devenv" / "python" / "shared" / "requirements-test.txt")]) == "pytest-xdist@CR@TBpytest-cov"
