
PROG_fnc_ConnectMysql = {
  if((isServer)) then {
  _result = "extDB3" callExtension "9:ADD_DATABASE:Database";
  diag_log _result;
  _result = "extDB3" callExtension "9:ADD_DATABASE_PROTOCOL:Database:SQL:SQL3";
  diag_log _result;
  _result = "extDB3" callExtension "9:ADD_DATABASE_PROTOCOL:Database:SQL_CUSTOM:custom4:custom.ini";
  diag_log _result;
  "extDB3" callExtension "9:LOCK:qwerty"
}
};
call PROG_fnc_ConnectMysql;

updateArsenal = {
  params ["_obj", "_items", "_UID"];
  _puid = getPlayerUID player;
  if(_puid isEqualTo _UID) then {
    [_obj, _items] call ace_arsenal_fnc_addVirtualItems;
  }
};

updateWallet = {
  params ["_uid", "_amount"];
  diag_log _this;
  _kill_civ = call compile ("extDB3" callExtension format ["0:SQL3:UPDATE main_Player SET money=money%2 WHERE UID = '%1';", _uid, _amount ]);
  diag_log _kill_civ;
};


_connect = addMissionEventHandler ["PlayerConnected",
{
	params ["_id", "_uid", "_name", "_jip", "_owner", "_idstr"];
  if((isServer)) then {
    diag_log _name;
    diag_log _uid;
    _ret = call compile ("extDB3" callExtension format ["0:custom4:getPlayer:%1", _uid]);
    _m_uid = (_ret select 1);
    _emtpyarr = [[""],[""]];
    diag_log "same?";
    diag_log _emtpyarr;
    diag_log _m_uid;
    if(_m_uid isEqualTo _emtpyarr ) then {
      diag_log "added to mysql";
      _ret1 = call compile ("extDB3" callExtension format ["1:SQL3:INSERT INTO main_Player(UID,name) VALUES('%1','%2');", _uid, _name]);
    } else {
      diag_log "already in mysql hust";
      _ret2 = call compile ("extDB3" callExtension format ["0:custom4:getItems:%1", _uid]);
      _test = (_ret2 select 1);
      _save = [];
      {
        diag_log (_x select 0);
        _save append _x ;
      } forEach _test;
      diag_log _save;
      //[arsenal, false] call ace_arsenal_fnc_initBox;
      //[arsenal, _save, _uid] remoteExec ["updateArsenal", -2];
    };
  }
}];


addMissionEventHandler ["EntityKilled",
{
	params ["_killed", "_killer", "_instigator"];
	if (isNull _instigator) then {_instigator = UAVControl vehicle _killer select 0}; // UAV/UGV player operated road kill
	if (isNull _instigator) then {_instigator = _killer}; // player driven vehicle road kill
  _uid = getPlayerUID _instigator;
  if (side player == civilian) then {
    if(player isEqualTo _instigator) then {
      if(player isNotEqualTo _killed) then {
     // systemChat "Confirmed CIV Kill, -100MC";
      _kill_enemy = [_uid, "-100"] remoteExec ["updateWallet", 2];
      diag_log "after call";
      diag_log _kill_enemy;
      diag_log _kill_civ;
      }
    }
  } else {
    if(player isEqualTo _instigator) then {
    //  systemChat "Confirmed Kill, +10MC";
      diag_log "before call";
      _uid = getPlayerUID _instigator;
      _kill_enemy = [_uid, "+10"] remoteExec ["updateWallet", 2];
      diag_log "after call";
      diag_log _kill_enemy;
    }}
}];

private _id = ["ace_treatmentSucceded", {
  params ["_caller", "_target", "_selectionName", "_className"];
  _try = (_this select 0);
  diag_log name (_this select 1);
  //systemChat str (_this select 0);
  //systemChat str (_this select 1);
  //systemChat str (_this select 3);
  diag_log _this;
  _medic =(_this select 0);
 // systemChat name _medic;
  diag_log getPlayerUID _medic;
 // systemChat str getPlayerUID _medic;
  _uid = getPlayerUID _medic;

  if(side _target == side _caller) then {
    if(_target isEqualTo _caller ) then {
    //  systemChat "self heal";
    } else {
     // systemChat "Good work +5MC";
      [_uid , "+5"] remoteExec ["updateWallet", 2];
    }
  } else {
   // systemChat "healed enemy!";
  }
  }] call CBA_fnc_addEventHandler;
