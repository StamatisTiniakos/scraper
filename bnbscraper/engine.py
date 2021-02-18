import sys
from logging import StreamHandler, getLogger, INFO
from .BnbScraper import main

_stderr_handler = StreamHandler(stream=sys.stderr)
_logger = getLogger('bnb_scraper')

_logger.addHandler(_stderr_handler)
_logger.setLevel(INFO)

if __name__ == '__main__':
    try:
        main()
    except (KeyboardInterrupt, SystemExit):
        print("Exiting")
        pass
    # Catch any exception so we can try to log it before exiting
    except:
        _logger.exception("Uncaught exception in main")
