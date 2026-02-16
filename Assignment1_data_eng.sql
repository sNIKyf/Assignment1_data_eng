DROP TABLE IF EXISTS drivers;
CREATE TABLE drivers (
    driver_id           VARCHAR,
    name                VARCHAR,
    nationality         VARCHAR,
    race_wins           INTEGER,
    points              DOUBLE,
    championship_wins   INTEGER,
    best_result         INTEGER,
    race_starts         INTEGER,
    podiums             INTEGER,
    race_laps           INTEGER,
    fastest_laps        INTEGER,
    driver_of_the_day   INTEGER,
    grand_slams         INTEGER);

INSERT INTO drivers
SELECT d.id,
    d.name,
    d.nationalityCountryId,
    d.totalRaceWins,
    d.totalPoints,
    d.totalChampionshipWins,
    d.bestRaceResult,
    d.totalRaceStarts,
    d.totalPodiums,
    d.totalRaceLaps,
    d.totalFastestLaps,
    d.totalDriverOfTheDay,
    d.totalGrandSlams
FROM read_json_auto('/Users/new/Downloads/f1db-json-single/f1db.json', maximum_object_size=600000000),
     UNNEST(drivers) AS t(d);

-- Drivers ranked by the amount of podiums by nationality
SELECT name,
    nationality,
    podiums,
    RANK() OVER (PARTITION BY nationality ORDER BY podiums DESC) as national_rank
FROM drivers
WHERE podiums > 0
ORDER BY nationality, national_rank;

-- The fastest driver
SELECT name,
    fastest_laps/race_laps AS fastest_laps_coef
FROM drivers
WHERE race_laps > 0
ORDER BY fastest_laps_coef DESC;

-- The percentage of wins each driver achieved for their country
SELECT name,
    nationality,
    race_wins,
    championship_wins,
    SUM(race_wins) OVER (PARTITION BY nationality) as country_total_wins,
    ROUND(100.0 * race_wins / NULLIF(SUM(race_wins) OVER (PARTITION BY nationality), 0), 2) as win_contribution,
    FIRST_VALUE(name) OVER (PARTITION BY nationality ORDER BY championship_wins DESC, race_wins DESC) as the_GOAT
FROM drivers
WHERE race_wins > 0 OR championship_wins > 0
ORDER BY country_total_wins DESC, race_wins DESC;




