import pytest, pandas as pd
from scripts.fetch_evebox_alerts import requests, resp
class Dummy:
    def __init__(self, code, j):
        self.status_code = code
        self._j = j
    def json(self):
        return self._j
def test_success(monkeypatch):
    dummy = Dummy(200, {"alerts":[{"src_ip":"1.1.1.1"}]})
    monkeypatch.setattr('requests.get', lambda *args,**kwargs: dummy)
    from scripts.fetch_evebox_alerts import fetch_evebox_alerts
    df = pd.json_normalize(dummy._j['alerts'])
    assert df.iloc[0]['src_ip']=='1.1.1.1'
def test_failure(monkeypatch):
    dummy = Dummy(500,{})
    monkeypatch.setattr('requests.get', lambda *args,**kwargs: dummy)
    import sys
    with pytest.raises(SystemExit):
        import scripts.fetch_evebox_alerts
