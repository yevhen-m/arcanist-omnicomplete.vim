import json
import urllib2


class BaseConduitClient(object):

    def __init__(self, api_url, api_token):
        self.api_url = api_url
        self.api_token = api_token

    def fetch_users(self):
        """Fetch all phabricator users."""
        data = self._make_request()
        return data['result']

    def _get_request_data(self):
        return 'api.token=%s' % self.api_token

    def _make_request(self):
        """Make a POST request to conduit's api."""
        response = urllib2.urlopen(
            url=self.api_url,
            data=self._get_request_data()
        )
        content = response.read()
        return json.loads(content.decode('utf8'))


class ConduitClient(BaseConduitClient):

    def _check_active(self, user):
        return 'disabled' not in user['roles']

    def fetch_users(self):
        """Fetch only active phabricator users."""
        users = super(type(self), self).fetch_users()
        return list(filter(self._check_active, users))
