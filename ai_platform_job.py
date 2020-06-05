from googleapiclient import discovery
from googleapiclient import errors

import logging

training_inputs = {
    'scaleTier': 'BASIC',
    'masterConfig': {
          "imageUri": 'gcr.io/bothub-273521/quickstart-image@sha256:f532b87cbb1c5db47586cff35a4afdfc3fefc23c3b8ad3174ef7688b3c503e8e',
    },
    'packageUris': ['gs://poc-training-ai-platform/job-dir/packages/82add65c49cb4a75897aec4b3832299824e68d494a47be7599d4904bace93912/ai-platform-poc-0.1.tar.gz'],
    'pythonModule': 'trainer.task',
    'args': ['--repository-version', 'sdasfwet', '--by-id', 'sapdjasoidjoa', '--repository-authorization', 'POIJSDOAISDJAS'],
    'region': 'us-east1',
    'jobDir': 'gs://poc-training-ai-platform/job-dir',
}

job_spec = {'jobId': 'my_training_job_3', 'trainingInput': training_inputs}

# Salve o ID do projeto no formato necessário para as APIs, "projects/projectname":
project_name = 'bothub-273521'
project_id = 'projects/{}'.format(project_name)

# Consiga uma representação em Python dos serviços do AI Platform Training:
cloudml = discovery.build('ml', 'v1')

# Crie e envie sua solicitação:
request = cloudml.projects().jobs().create(body=job_spec,
              parent=project_id)

try:
    response = request.execute()
    # You can put your code for handling success (if any) here.
    print("SUCCESS!!!")

except errors.HttpError as err:
    # Do whatever error response is appropriate for your application.
    # For this example, just send some text to the logs.
    # You need to import logging for this to work.
    logging.error('/n There was an error creating the training job.'
                  ' Check the details:')
    logging.error(err._get_reason())