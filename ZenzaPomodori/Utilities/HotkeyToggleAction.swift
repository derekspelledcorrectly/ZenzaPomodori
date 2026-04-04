enum HotkeyToggleAction: Equatable {
    case showActivated
    case activate
    case hide
}

func hotkeyToggleAction(panelVisible: Bool, panelIsKey: Bool) -> HotkeyToggleAction {
    guard panelVisible else { return .showActivated }
    return panelIsKey ? .hide : .activate
}
