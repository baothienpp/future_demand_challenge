import unittest
from src.anagram.main import is_anagram


class TestAnagram(unittest.TestCase):
    def test_empty_string(self):
        self.assertEqual(is_anagram("", ""), True)

    def test_one_empty_string(self):
        self.assertEqual(is_anagram("a", ""), False)

    def test_one_empty_string_1(self):
        self.assertEqual(is_anagram("", "a"), False)

    def test_1(self):
        self.assertEqual(is_anagram("A", "A"), True)

    def test_2(self):
        self.assertEqual(is_anagram("A", "B"), False)

    def test_3(self):
        self.assertEqual(is_anagram("ab", "ba"), True)

    def test_4(self):
        self.assertEqual(is_anagram("AB", "ab"), False)

    def test_5(self):
        self.assertEqual(is_anagram("AB", "ba"), False)


if __name__ == '__main__':
    unittest.main()
