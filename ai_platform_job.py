from googleapiclient import discovery
from googleapiclient import errors

import logging

training_inputs = {
    'scaleTier': 'CUSTOM',
    'masterType': 'standard_p100',
    # 'workerType': 'standard_v100',
    # 'workerCount': 3,
    # 'parameterServerType': 'n1-highmem-8',
    # 'evaluatorType': 'n1-highcpu-16',

    # 'parameterServerCount': 3,
    # 'evaluatorCount': 1,

    'masterConfig': {
        "imageUri": 'us.gcr.io/bothub-273521/bothub-nlp-ai-platform:1.0.15',
    },
    'packageUris': [
        'gs://poc-training-ai-platform/bothub-nlp-ai-platform/bothub-nlp-ai-platform-0.1.tar.gz'
    ],
    'pythonModule': 'trainer.train',
    'args': ['--repository-version', '20072', '--by-id', '298', '--repository-authorization', '9b72d9ab-90b1-47a6-9225-bb8c33d9f071'],
    'region': 'us-east1',
    'jobDir': 'gs://poc-training-ai-platform/job-dir',
}

job_spec = {'jobId': 'bothub_train_daniel_15', 'trainingInput': training_inputs}

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