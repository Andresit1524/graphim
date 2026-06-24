# Ponytail audit

- [X] Delete Unused plugin `vector_display_2d` and its settings file. Remove the addon directory, its registration in `project.godot`, and `vd_settings.tres`. [`addons/vector_display_2d/`]
- [ ] Delete Random initialization debug code in `_ready()` that overrides edge endpoints. Delete lines 39-44. [`assets/graph_edge/graphim_edge.gd`]
- [ ] Delete Unused signals `extremes_changed` and `weight_changed`. Remove signal definitions and their emissions in setters. [`assets/graph_edge/edge_data.gd`]
- [ ] Delete Empty `_update_edges()` function and its redundant signal connection. Remove the function and the connection line. [`assets/world/world.gd`]
- [X] Delete Empty test directory. Remove the directory. [`test/`]
