package ui

type MenuItem struct {
	Index string
	Desc  string
	Run   func()
}

func (mi MenuItem) IsRunnable() bool {
	return mi.Run != nil
}

func (mi MenuItem) HasIndex() bool {
	return mi.Index != ""
}

func (mi MenuItem) String() string {
	var s string
	if mi.HasIndex() {
		s += mi.Index + " "
	}
	s += mi.Desc

	return s
}
