# Cloudprint Change Log

## [0.3.2] - 2017-11-13
### Fixes
- Fix add uiState to print job to show errors.

## [0.3.1] - 2016-03-10
### Fixes
- Fix search_all delegating to an invalid query.
- Turn the method_missing magic inside PrinterCollection into simple explicit code.
## [0.3.0] - 2016-03-09
### Dependencies
- Update oauth gem requirement since a lot of people were having issues with that.
- Change test_unit to minitest due to my own issues with the build and test_unit being really old.
### Fixes
- Removed a few warnings that were raised during the build.
