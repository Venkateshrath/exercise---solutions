import unittest
from app import app

class TestApp(unittest.TestCase):
    def test_home(self):
        tester = app.test_client()
        response = tester.get("/")
        decoded_output = response.data.decode("utf-8")
        print(f"\n[TEST LOG] Response: {decoded_output}")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(decoded_output, "Hello, Jenkins Multi-Stage Pipeline!")

if __name__ == "__main__":
    unittest.main()
