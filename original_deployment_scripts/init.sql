# data lake core databases
CREATE DATABASE IF NOT EXISTS `ulake-core`;
CREATE DATABASE IF NOT EXISTS `ulake-folder`;
CREATE DATABASE IF NOT EXISTS `ulake-user`;
CREATE DATABASE IF NOT EXISTS `ulake-acl`;
CREATE DATABASE IF NOT EXISTS `ulake-table`;


# additional services databases
CREATE DATABASE IF NOT EXISTS `ulake-search`;
CREATE DATABASE IF NOT EXISTS `ulake-log`;
CREATE DATABASE IF NOT EXISTS `ulake-ir`;
CREATE DATABASE IF NOT EXISTS `ulake-extract`;
CREATE DATABASE IF NOT EXISTS `ulake-compress`;
CREATE DATABASE IF NOT EXISTS `ulake-ingestion`;
CREATE DATABASE IF NOT EXISTS `ulake-lcc`;

# frontend services  databases
CREATE DATABASE IF NOT EXISTS `ulake-admin`;

