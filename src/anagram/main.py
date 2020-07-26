import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def is_anagram(str1, str2):
    return str1 == str2[::-1]


def handler(event, context):
    logging.info(event)
    logging.info("message: " + str(is_anagram("abcde", "edcba")))
    return {
        "message": is_anagram("abcde", "edcba")
    }