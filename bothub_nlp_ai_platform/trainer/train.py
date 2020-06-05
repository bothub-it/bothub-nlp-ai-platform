import argparse
import os

from bothub_nlp_rasa_utils.train import train


if __name__ == '__main__':
    PARSER = argparse.ArgumentParser()

    # Input Arguments
    PARSER.add_argument(
        '--repository-version',
        help='The version of repository.',
        type=int)
    PARSER.add_argument(
        '--by-id',
        help='.')
    PARSER.add_argument(
        '--repository-authorization',
        help='Repository authorization string.')

    ARGUMENTS, _ = PARSER.parse_known_args()
    # Run the training job
    train(ARGUMENTS.repository_version, ARGUMENTS.by_id, ARGUMENTS.repository_authorization)