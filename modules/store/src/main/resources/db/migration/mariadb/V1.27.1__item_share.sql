CREATE TABLE `item_share` (
  `id` varchar(254) not null primary key,
  `user_id` varchar(254) not null,
  `name` varchar(254),
  `query` varchar(2000) not null,
  `enabled` boolean not null,
  `pass` varchar(254),
  `publish_at` timestamp not null,
  `publish_until` timestamp not null,
  `views` int not null,
  `last_access` timestamp,
  foreign key (`user_id`) references `user_`(`uid`) on delete cascade
)
