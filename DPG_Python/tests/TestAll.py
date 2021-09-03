# Test all unit test found in this directory
# source : stackoverflow.com/questions/1732438/how-do-i-run-all-python-unit-tests-in-a-directory
import unittest
loader = unittest.TestLoader()
start_dir = '.'
suite = loader.discover(start_dir)
runner = unittest.TextTestRunner()
runner.run(suite)
