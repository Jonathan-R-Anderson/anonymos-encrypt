module Common.SCard;

import Common.SCardManager;

class SCard
{
    static SCardManager manager = new SCardManager();
    this(){}
    this(size_t slotId){ }
    ~this(){}
    bool isCardHandleValid() const { return false; }
}
