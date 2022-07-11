# Drone Plugin to Deploy to Vercel

A [Drone](https://drone.io) plugin to deploy a an application to [Vercel](https://vercel.com/).

## Usage

The following settings changes this plugin's behavior.

* `vercel_token`: The Vercel Token to use
* `vercel_org_id`: The organization id to use with Vercel deployment
* `vercel_project_id` The Vercel Project Name or ID.
* `vercel_project_create`: (optional) If true then  name of the project specified by __vercel_project_id__ will be created and site will be deployed to that project. Defaults `false`.
* `vercel_environment`: (optional) The vercel environment to deploy. It could be one of `development`, `preview` or `production`. Defaults to `development`
* `vercel_environment_variables`: (optional) An array of __KEY=VALUE__ pair of environment variables will be added to site project at __vercel_environment__ scope.
* `log_level`:  If set to debug enable scripting debug

To use the plugin create a secret file called `secret.local` with following variables,

```text
vercel_token=The Vercel token to use
vercel_project_id=The Vercel project Id
vercel_org_id=The Vercel Organization Id
```

Create a `.drone.yml` as shown below and then run the command `drone exec --secret-file=.secret.local`

```yaml
kind: pipeline
type: docker
name: default
platform:
  os: linux
  arch: amd64
steps:
- name: deploy
  image: docker.io/kameshsampath/drone-vercel-deploy
  pull: never
  settings:
    log_level: debug
    # valid values are production, development, preview
    vercel_env: production
    vercel_token:
      from_secret: vercel_token
    vercel_org_id:
      from_secret: vercel_org_id
    vercel_project_id:
      from_secret: vercel_project_id
    vercel_project_create: true
    vercel_environment:
    - NEXT_PUBLIC_FOO=BAR
    - NEXT_PUBLIC_XMAS=25 Dec
```

## Building

Run the following command to build and push the image manually

```text
make build-and-load
```

## Testing

To use the plugin create a secret file called `secret.local` ,

```shell
cd $PROJECT_HOME/examples
cp secret.example secret.local
```

Update the `secret.local` with values for,

* vercel_token
* vercel_org_id
* vercel_project_id

```shell
drone exec --secret-file=secret.local .drone.yml
```
