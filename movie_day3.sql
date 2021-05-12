SELECT *
FROM movies
WHERE to_tsvector('english', title) @@ to_tsquery('english', 'star & war');

create index idx_movies_title_words on movies using gin (to_tsvector('english', title));

insert into movies (title, year) values ('The War of Stars', 2021);
update movies set title = 'The War of Roses' where id = 12771924;

show default_text_search_config;

delete from play where id_movie % 2 = 0;

