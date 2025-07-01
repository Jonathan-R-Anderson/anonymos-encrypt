module Driver.VolumeFilter;

extern(C):

alias uint32_t = uint;
extern __gshared uint HiddenSysLeakProtectionCount;

struct DRIVER_OBJECT; struct DEVICE_OBJECT; struct IRP;

alias PDRIVER_OBJECT = DRIVER_OBJECT*;
alias PDEVICE_OBJECT = DEVICE_OBJECT*;
alias PIRP = IRP*;

int VolumeFilterAddDevice(PDRIVER_OBJECT driverObject, PDEVICE_OBJECT pdo);
int VolumeFilterDispatchIrp(PDEVICE_OBJECT deviceObject, PIRP irp);
