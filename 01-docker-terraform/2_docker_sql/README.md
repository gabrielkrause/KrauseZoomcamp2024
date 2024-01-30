# Commands executed to create and run containers

```console
docker network create pg-network
```
```console
docker run -it \
    -e POSTGRES_USER="root" \
    -e POSTGRES_PASSWORD="root" \
    -e POSTGRES_DB="ny_taxi" \
    -v $(pwd)/ny_taxi_postgres_data:/var/lib/postgresql/data \
    -p 5432:5432 \
    --network=pg-network \
    --name pg-database \
    postgres:13

 docker run -it \
  -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" \
  -e PGADMIN_DEFAULT_PASSWORD="root" \
  -p 8080:80 \
  --network=pg-network \
  --name pgadmin \
  dpage/pgadmin4
```
```console
URL="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz"

python ingest_data.py \
    --user=root \
    --password=root \
    --host=localhost \
    --port=5432 \
    --db=ny_taxi \
    --table_name=yellow_taxi_trips \
    --url=${URL}
```

```console
docker build -t taxi_ingest:v001 .

docker run -it \
    --network=pg-network \
    taxi_ingest:v001 \
    --user=root \
    --password=root \
    --host=pg-database \
    --port=5432 \
    --db=ny_taxi \
    --table_name=yellow_taxi_trips \
    --url=${URL}
```

### To ingest data to the Postgres DB created using docker-compose 
### Container runs from the image built from the Dockerfile

```console
docker build -t taxi_ingest:v002 .

URL_TAXI="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2019-09.csv.gz"
URL_ZONES="https://s3.amazonaws.com/nyc-tlc/misc/taxi+_zone_lookup.csv"

docker run -it \
    --network=2_docker_sql_default \
    taxi_ingest:v002 \
    --user=root \
    --password=root \
    --host=pgdatabase \
    --port=5432 \
    --db=ny_taxi \
    --table_name=green_taxi_trips \
    --url_taxi_data=${URL_TAXI} \
    --url_zones_data=${URL_ZONES}
```

# Queries related to the answers to Week 1 questions

https://github.com/DataTalksClub/data-engineering-zoomcamp/blob/main/cohorts/2024/01-docker-terraform/homework.md

## Question 3. Count records

```sql
SELECT
	CAST(lpep_pickup_datetime as DATE) as "day_pickup",
	COUNT(1)
FROM
	green_taxi_trips t
WHERE
    CAST(lpep_pickup_datetime AS DATE) = CAST(lpep_dropoff_datetime AS DATE)
GROUP BY
	CAST(lpep_pickup_datetime as DATE)
ORDER BY 
	"day_pickup" ASC;
```
Answer: **15612**

## Question 4. Longest trip for each day

```sql
SELECT
    CAST(lpep_pickup_datetime AS DATE) AS "day_pickup",
    MAX(trip_distance) AS max_trip_distance
FROM
    green_taxi_trips t 
GROUP BY
    CAST(lpep_pickup_datetime AS DATE)
ORDER BY
    max_trip_distance DESC;
```
Answer: **2019-09-26**

## Question 5. Three biggest pick up Boroughs

```sql
SELECT
    zpu."Borough" AS pickup_borough,
    SUM(t.total_amount) AS total_amount_sum
FROM
    green_taxi_trips t
JOIN
    zones zpu ON t."PULocationID" = zpu."LocationID"
WHERE
    CAST(t.lpep_pickup_datetime AS DATE) = '2019-09-18'
    AND zpu."Borough" != 'Unknown'
GROUP BY
    zpu."Borough"
HAVING
    SUM(t.total_amount) > 50000
ORDER BY
    total_amount_sum DESC
LIMIT 3;
```
Answer: **"Brooklyn" "Manhattan" "Queens"**

## Question 6. Largest tip

```sql
WITH AstoriaPickups AS (
    SELECT
        t.*,
        zdo."Zone" AS dropoff_zone_name
    FROM
        green_taxi_trips t
    JOIN
        zones zpu ON t."PULocationID" = zpu."LocationID"
    JOIN
        zones zdo ON t."DOLocationID" = zdo."LocationID"
    WHERE
        zpu."Zone" = 'Astoria'
        AND EXTRACT(YEAR FROM t.lpep_pickup_datetime) = 2019
        AND EXTRACT(MONTH FROM t.lpep_pickup_datetime) = 9
)

SELECT
    dropoff_zone_name,
    MAX(tip_amount) AS max_tip_amount
FROM
    AstoriaPickups
GROUP BY
    dropoff_zone_name
ORDER BY
    max_tip_amount DESC
LIMIT 1;
```
Answer: **JFK Airport**