module Main.Forms.VolumePimWizardPage;

class VolumePimWizardPage : VolumePimWizardPageBase
{
    this(wxPanel parent)
    {
        super(parent);
        VolumePimTextCtrl.setMinSize(wxSize(Gui.getCharWidth(VolumePimTextCtrl) * 15, -1));
        setPimValidator();
    }
    ~this() {}
    int getVolumePim() const
    {
        if (VolumePimTextCtrl.isEnabled())
        {
            auto pimStr = VolumePimTextCtrl.getValue();
            long pim = 0;
            if (pimStr.isEmpty()) return 0;
            if (pimStr.findFirstNotOf("0123456789") == wxNOT_FOUND && pimStr.toLong(&pim) && pim <= MAX_PIM_VALUE)
                return cast(int)pim;
            else
                return -1;
        }
        else return 0;
    }
    void setVolumePim(int pim)
    {
        if (pim > 0)
            VolumePimTextCtrl.setValue(StringConverter.fromNumber(pim));
        else
            VolumePimTextCtrl.setValue(wxT(""));
        onPimValueChanged(pim);
    }
    bool isValid() { return true; }
    void onPimChanged(wxCommandEvent event) { onPimValueChanged(getVolumePim()); }
    void onPimValueChanged(int pim)
    {
        if (pim > 0)
        {
            VolumePimHelpStaticText.setForegroundColour(*wxRED);
            VolumePimHelpStaticText.setLabel(LangString["PIM_CHANGE_WARNING"]);
        }
        else
        {
            VolumePimHelpStaticText.setForegroundColour(wxSystemSettings.getColour(wxSYS_COLOUR_WINDOWTEXT));
            VolumePimHelpStaticText.setLabel(LangString["IDC_PIM_HELP"]);
        }
        Fit();
        Layout();
    }
    void setPimValidator()
    {
        wxTextValidator validator(wxFILTER_DIGITS);
        VolumePimTextCtrl.setValidator(validator);
    }
    void onDisplayPimCheckBoxClick(wxCommandEvent event)
    {
        FreezeScope freeze(this);
        bool display = event.isChecked();
        auto newText = new wxTextCtrl(this, wxID_ANY, wxEmptyString, wxDefaultPosition, wxDefaultSize, display ? 0 : wxTE_PASSWORD);
        newText.setMaxLength(MAX_PIM_DIGITS);
        newText.setValue(VolumePimTextCtrl.getValue());
        newText.setMinSize(VolumePimTextCtrl.getSize());
        PimSizer.replace(VolumePimTextCtrl, newText);
        VolumePimTextCtrl.show(false);
        int txtLen = VolumePimTextCtrl.getLineLength(0);
        if (txtLen > 0)
            VolumePimTextCtrl.setValue(wxString('X', txtLen));
        getVolumePim();
        Fit();
        Layout();
        newText.setMinSize(VolumePimTextCtrl.getMinSize());
        newText.connect(wxEVT_COMMAND_TEXT_UPDATED, &onPimChanged);
        delete VolumePimTextCtrl;
        VolumePimTextCtrl = newText;
        setPimValidator();
        onPimValueChanged(getVolumePim());
    }
}
