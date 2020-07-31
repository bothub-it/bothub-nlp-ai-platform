import argparse
from bothub_nlp_rasa_utils.train import train_update as train
import os
print(os.getcwd())

if __name__ == '__main__':
    PARSER = argparse.ArgumentParser()

    # Input Arguments
    PARSER.add_argument(
        '--repository-version',
        help='The version of repository.',
        type=int)
    PARSER.add_argument(
        '--by-id',
        help='.',
        type=int)
    PARSER.add_argument(
        '--repository-authorization',
        help='Repository authorization string.')

    ARGUMENTS, _ = PARSER.parse_known_args()
    # Run the training job
    train(ARGUMENTS.repository_version, ARGUMENTS.by_id, ARGUMENTS.repository_authorization, from_queue='ai-platform')
