# BagelTracker

## Crontab Daily

@daily cd "/home/bandtracker/deployed_application/bagel_tracker/"; MIX_ENV=prod mix run -e UpdateSiteData.start_data_update