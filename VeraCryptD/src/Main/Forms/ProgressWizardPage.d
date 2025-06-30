module Main.Forms.ProgressWizardPage;

class ProgressWizardPage : ProgressWizardPageBase
{
    shared(wxTimer) mTimer;
    int previousGaugeValue = 0;
    ulong progressBarRange = 1;
    int realProgressBarRange = 1;
    Event abortEvent;
    SharedVal!ulong progressValue;

    this(wxPanel parent, bool enableAbort = false)
    {
        super(parent);
        progressValue.set(0);
        ProgressGauge.setValue(0);
        AbortButton.show(enableAbort);
        mTimer = new wxTimer();
        mTimer.connect(&onTimer);
        mTimer.start(30);
    }

    void enableAbort(bool enable = true) { AbortButton.enable(enable); }
    bool isValid() { return true; }
    void setMaxStaticTextWidth(int width) { InfoStaticText.wrap(width); }
    void setPageText(string text) { InfoStaticText.setLabel(text); }

    void setProgressRange(ulong range)
    {
        progressBarRange = range;
        realProgressBarRange = ProgressGauge.getSize().getWidth();
        ProgressGauge.setRange(realProgressBarRange);
    }

protected:
    void onAbortButtonClick(wxCommandEvent event) { abortEvent.raise(); }
    void onTimer()
    {
        auto value = progressValue.get();
        int gauge = cast(int)(value * realProgressBarRange / progressBarRange);
        if (value == progressBarRange)
            gauge = realProgressBarRange;
        if (gauge != previousGaugeValue)
        {
            ProgressGauge.setValue(gauge);
            previousGaugeValue = gauge;
        }
    }
}
