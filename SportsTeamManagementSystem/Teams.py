import mongodb as d
import datetime as dt

class Teams:
    def __init__(self):
        self._name = ''
        self._city = ''
        self._total_players = 0
        self._entry_fee = False
        self._registered_date = dt.datetime.utcnow()

    def set_name(self, name):
        self._name = name

    def set_city(self, city):
        self._city = city

    def set_total_players(self, total_players):
        self._total_players = total_players

    def set_entry_fee(self, entry_fee):
        self._entry_fee = entry_fee

    def register_team(self):
        team_data = {
            "name": self._name,
            "city": self._city,
            "total_players": self._total_players,
            "entry_fee": self._entry_fee,
            "registered_date": self._registered_date
        }

        d.insert_team(team_data)

    def update_team(self, id):
        team_data = {
            "name": self._name,
            "city": self._city,
            "total_players": self._total_players,
            "entry_fee": self._entry_fee
        }

        d.update_team_data(team_data, id)
