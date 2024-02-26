# Snowpark Container Services: dbt implementation
Integration between Snowpark Container Services and dbt (data build tool). This application represents a significant leap in data transformation and workflow management, harnessing the power of Snowflake's advanced data processing capabilities alongside dbt's efficient modeling and transformation features, designed for modern data teams.

## Requirements
* [Snowflake](https://signup.snowflake.com/)
* [Snowflake CLI](https://github.com/Snowflake-Labs/snowcli)
* [Docker community edition](https://hub.docker.com/search/?type=edition&offering=community)

## Installation
0. Clone this repository locally.
1. Login to your Snowflake account and create the following resources: database, warehouse, SP, etc.
	* Run the scrip under `setup/01_resources.sql`.
	* Copy the registry URI witch it will be shown after `SHOW IMAGE REPOSITORIES;` command is run.
2. Paste the URI in the `.env` file in the `IMAGEREPOSITORYURI` variable.
3. Open a terminal and navegate to the `spcs-dbt` directory
   * Run the following command in the terminal `make push-docker-image-registry`.
   * You can take a look at the image in the registry by running `SELECT SYSTEM$REGISTRY_LIST_IMAGES('/FOOBAR_DB/PUBLIC/images');`.
4. Configure a conneciton for the [Snowflake CLI](https://github.com/Snowflake-Labs/snowcli) to use the user `dockeruser` created in `setup/01_resources.sql` and name the connection `dbt`.

## dbt Models
<img width="1705" alt="image" src="https://user-images.githubusercontent.com/107192982/182833850-5d4285cf-f7be-42b1-a488-a6c68ecf4bc1.png">

Once you have up and running the code head over to: `http://localhost:8001/#!/overview?g_v=1` the model called 
`stg_market_region_enhance` (highlighted in the picture above) is the snowpark model being orchestrated by dbt.

## Usage

You can use this as a local demo, no dbt cloud is required.

## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D
