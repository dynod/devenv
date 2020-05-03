from helpers.list_requirements import main
from tests.test_shared import TestHelpers


class TestSettingsBuilderHelper(TestHelpers):
    def test_list_requirements(self):
        assert main([str(self.root_folder / ".devenv" / "python" / "shared" / "requirements-test.txt")]) == "pytest-xdist@CR@TBpytest-cov@CR@TBpytest-multilog"
