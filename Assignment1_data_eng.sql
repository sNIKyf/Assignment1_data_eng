CREATE TABLE drivers AS
SELECT d.id AS driver_id,
    d.name,
    d.nationalityCountryId AS nationality,
    d.totalRaceWins AS race_wins,
    d.totalPoints AS points,
    d.totalChampionshipWins AS championship_wins,
    d.bestRaceResult AS best_result,
    d.totalRaceStarts AS race_starts,
    d.totalPodiums AS podiums,
    d.totalRaceLaps AS race_laps,
    d.totalFastestLaps AS fastest_laps,
    d.totalDriverOfTheDay AS driver_of_the_day,
    d.totalGrandSlams AS grand_slams
FROM (
    SELECT unnest(drivers) AS d
    FROM read_json_auto('/Users/new/Downloads/f1db-json-single/f1db.json', maximum_object_size=500000000));

SELECT name,
    nationality,
    podiums,
    RANK() OVER (PARTITION BY nationality ORDER BY podiums DESC) as national_rank
FROM drivers
WHERE podiums > 0
ORDER BY nationality, national_rank;

SELECT name,
    fastest_laps/race_laps AS fastest_laps_coef
FROM drivers
WHERE race_laps > 0
ORDER BY fastest_laps_coef DESC;

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




