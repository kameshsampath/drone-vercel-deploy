# Drone Plugin to Deploy to Vercel

A [Drone](https://drone.io) plugin to deploy a node application to [Vercel](https://vercel.com/).

## Usage

The following settings changes this plugin's behavior.

* vercel_token The Vercel Token to use
* vercel_org_id The organization id to use with Vercel deployment
* vercel_project_id (optional) The Vercel Project Name or ID.
* vercel_project_create (optional) If true then  name of the project specified by `vercel_project_id` will be created and site will be deployed to that project.
* environment (optional) An array of `KEY=VALUE` pair of environment variables that needs to be set to the site runtime

To use the plugin create a secret file called `.env` with following variables,

```text
vercel_token=The Vercel token to use
vercel_project_id=The Vercel project Id
vercel_org_id=The Vercel Organization Id
```

Create a `.drone.yml` as shown below and then run the command `drone exec --secret-file=.env`

```yaml
kind: pipeline
type: docker
name: gcloud-auth

steps:

- name: configure gcloud
  image: quay.io/kameshsampath/drone-gcloud-auth
  pull: if-not-exists
  settings:
    google_application_credentials:
      from_secret: service_account_json
    google_cloud_project:
      from_secret: google_cloud_project
    registries:
      - asia.gcr.io
      - eu.gcr.io
  volumes:
    - name: gcloud-config
      path: /home/dev/.config/gcloud

- name: view the config
  image: quay.io/kameshsampath/drone-gcloud-auth
  pull: if-not-exists
  commands:
    - gcloud config list
  volumes:
    - name: gcloud-config
      path: /home/dev/.config/gcloud

volumes:
  - name: gcloud-config
    temp: {}
```

Please check the examples folder for `.drone.yml` with other settings.

## Building

Run the following command to build and push the image manually

```text
./scripts/build.sh
```

## Testing

To use the plugin create a secret file called `.env` with following variables,

```text
google_cloud_project=foo
service_account_json=The JSON string of Service Account JSON
```

```shell
drone exec --secret-file=.env examples/.drone-registries.yml
```
