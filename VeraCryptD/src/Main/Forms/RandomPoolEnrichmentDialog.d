module Main.Forms.RandomPoolEnrichmentDialog;

class RandomPoolEnrichmentDialog : RandomPoolEnrichmentDialogBase
{
    size_t mouseEventsCounter = 0;
    this(wxWindow parent)
    {
        super(parent);
        RandomNumberGenerator.start();
        auto hashes = Hash.getAvailableAlgorithms();
        foreach(hash; hashes)
        {
            if (!hash.isDeprecated())
            {
                HashChoice.append(hash.getName(), hash.ptr);
                if (typeid(hash) == typeid(*RandomNumberGenerator.getHash()))
                    HashChoice.select(HashChoice.getCount()-1);
            }
        }
        hideBytes(RandomPoolStaticText, 24);
        MouseStaticText.wrap(Gui.getCharWidth(MouseStaticText) * 70);
        CollectedEntropy.setRange(RNG_POOL_SIZE * 8);
        MainSizer.setMinSize(wxSize(-1, Gui.getCharHeight(this) * 24));
        Layout();
        Fit();
        Center();
        foreach(c; this.getChildren())
            c.connect(wxEVT_MOTION, &onMouseMotion);
    }
    ~this() {}

    void onHashSelected(wxCommandEvent event)
    {
        RandomNumberGenerator.setHash(cast(Hash*)Gui.getSelectedData!Hash(HashChoice)).getNew();
    }
    void onMouseMotion(wxMouseEvent event)
    {
        event.skip();
        RandomNumberGenerator.addToPool(cast(ubyte*)&event, event.sizeof);
        long coord = event.getX();
        RandomNumberGenerator.addToPool(cast(ubyte*)&coord, coord.sizeof);
        coord = event.getY();
        RandomNumberGenerator.addToPool(cast(ubyte*)&coord, coord.sizeof);
        if (ShowRandomPoolCheckBox.isChecked())
            showBytes(RandomPoolStaticText, RandomNumberGenerator.peekPool()[0 .. 24]);
        else
            hideBytes(RandomPoolStaticText, 24);
        scope(exit) {}
        if (mouseEventsCounter < RNG_POOL_SIZE*8)
            CollectedEntropy.setValue(++mouseEventsCounter);
    }
    void onShowRandomPoolCheckBoxClicked(wxCommandEvent event)
    {
        if (!event.isChecked())
            hideBytes(RandomPoolStaticText, 24);
    }
    void showBytes(wxStaticText ctrl, const(ubyte)[] buffer)
    {
        wxString str;
        foreach(b; buffer)
            str ~= wxString.format("%02X", b);
        str ~= "..";
        ctrl.setLabel(str);
    }
    void hideBytes(wxStaticText ctrl, size_t len)
    {
        wxString str;
        foreach(i; 0 .. len+1)
            str ~= "**";
        ctrl.setLabel(str);
    }
}
