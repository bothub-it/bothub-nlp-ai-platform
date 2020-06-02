from setuptools import find_packages
from setuptools import setup

REQUIRED_PACKAGES = ['rasa==1.10.1', 'git+https://github.com/bothub-it/bothub-nlp-celery.git@0.1.15',
                    'git+https://github.com/bothub-it/bothub-backend.git@1.0.9',
                    'git+https://github.com/bothub-it/bothub-nlp-rasa-utils.git',
                    'google-api-python-client==1.8.0'
                    ]

setup(
    name='bothub-nlp-ai-platform',
    version='0.1',
    install_requires=REQUIRED_PACKAGES,
    packages=find_packages(),
    include_package_data=False,
    description='Bothub training application.'
)
