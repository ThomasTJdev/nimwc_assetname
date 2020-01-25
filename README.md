# Nim Website Creator - Asset naming
[Nim Website Creator](https://github.com/ThomasTJdev/nim_websitecreator) plugin to name assets.



# Changelog
## v0.3
```
ALTER TABLE asset_data ADD COLUMN oldtag VARCHAR(1000);
ALTER TABLE asset_data ADD COLUMN supplier VARCHAR(1000);
```

## v0.2
```
ALTER TABLE asset_types ADD COLUMN strictidnr VARCHAR(10);
```