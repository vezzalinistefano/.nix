/*
 * vcsfw — TOD driver skeleton for the Validity/Synaptics 06cb:009a
 *
 * Phase 6 starting point. It registers the type, claims the USB ID and fails every
 * action cleanly, so `fprintd-list` shows a device and `fprintd-enroll` says
 * "not supported" instead of "no devices". Everything protocol-shaped is a TODO.
 *
 * Shape follows libfprint's TOD examples: one FpiDevice subclass, an SSM per action,
 * `fpi_tod_shared_driver_get_type()` as the entry point. Read
 * libfprint/drivers/synaptics/ in the libfprint tree before filling anything in — same
 * match-on-chip family, and it gets the interrupt/polling dance right.
 */

#define FP_COMPONENT "vcsfw"

#include "drivers_api.h"

/* Endpoints from the reader's descriptor dump (notes/descriptors-*.txt). */
#define EP_OUT (1 | FPI_USB_ENDPOINT_OUT)
#define EP_IN (1 | FPI_USB_ENDPOINT_IN)
#define EP_DATA_IN (2 | FPI_USB_ENDPOINT_IN)
#define EP_INT (FPI_USB_ENDPOINT_IN | 3 | FPI_USB_TRANSFER_INTERRUPT)

/* Status word: little-endian uint16 in front of every answer. */
#define VCSFW_STATUS_OK 0x0000
#define VCSFW_STATUS_SIGNATURE 0x044f

typedef struct _FpiDeviceVcsfw
{
  FpDevice parent;

  /* TLS session state: 0x120-byte key block, sequence of the record layer, and the
   * per-device seed read during init (see docs/02-handshake.md). */
  guint8 key_block[0x120];
  gboolean session_up;

  /* Reused transfer buffer. One writer at a time, one command in flight. */
  guint8 *buffer;
  gsize buffer_len;

  GCancellable *cancellable;
} FpiDeviceVcsfw;

G_DECLARE_FINAL_TYPE (FpiDeviceVcsfw, fpi_device_vcsfw, FPI, DEVICE_VCSFW, FpDevice)

G_DEFINE_TYPE (FpiDeviceVcsfw, fpi_device_vcsfw, FP_TYPE_DEVICE)

/* ------------------------------------------------------------------ transport -- */

/*
 * One command, one answer, in order. USB already frames the transfer, so the request
 * goes out exactly as built — no length prefix, no request id. A late answer therefore
 * shifts every later one, so serialise strictly.
 *
 * TODO: implement with fpi_usb_transfer helpers; check the status word here, not at the
 * call site, so a failure can never be mistaken for a payload.
 */
static gboolean
vcsfw_cmd (FpiDeviceVcsfw *self, const guint8 *request, gsize request_len, guint8 **response, gsize *response_len, GError **error)
{
  (void) self;
  (void) request;
  (void) request_len;
  (void) response;
  (void) response_len;
  g_set_error_literal (error, G_IO_ERROR, G_IO_ERROR_NOT_SUPPORTED, "vcsfw_cmd: TODO");
  return FALSE;
}

/*
 * Poll EP 0x83 until a record with the wanted first byte arrives:
 *   0x00 capture started, 0x02 finger present,
 *   0x03 state update — third byte bit 0x04 means capture complete.
 * Timeout in ~100 ms units, as the reference implementations do.
 *
 * TODO: implement. Note that 0x03 is not always "complete", and a capture may also end
 * in 0x03 without the bit set — do not treat it as terminal.
 */
static gboolean
vcsfw_wait_int (FpiDeviceVcsfw *self, guint8 wanted, guint8 *record, gsize record_len, GError **error)
{
  (void) self;
  (void) wanted;
  (void) record;
  (void) record_len;
  g_set_error_literal (error, G_IO_ERROR, G_IO_ERROR_NOT_SUPPORTED, "vcsfw_wait_int: TODO");
  return FALSE;
}

/* ---------------------------------------------------------------------- open -- */

static void
open_ssm (FpSsm *ssm, void *user_data)
{
  FpiDeviceVcsfw *self = FPI_DEVICE_VCSFW (fpi_ssm_get_data (ssm));

  switch (fpi_ssm_get_cur_state (ssm))
  {
  /* TODO: INIT_MSG1..3 (01, 19, 4302), then the INIT_MSG4 blob, then 3e and 40.
   * Then the TLS handshake. Then a GET_VERSION to confirm the silicon. */
  case 0:
    fpi_ssm_next_state (ssm);
    break;
  case 1:
    fpi_ssm_mark_completed (ssm);
    break;
  default:
    g_assert_not_reached ();
  }
}

static void
dev_open (FpDevice *device)
{
  FpiDeviceVcsfw *self = FPI_DEVICE_VCSFW (device);
  FpSsm *ssm = fpi_ssm_new (device, open_ssm, 2);

  fpi_ssm_set_data (ssm, self, NULL);
  fpi_ssm_start (ssm, NULL);
}

/* --------------------------------------------------------------------- close -- */

static void
dev_close (FpDevice *device)
{
  FpiDeviceVcsfw *self = FPI_DEVICE_VCSFW (device);

  (void) self;
  /* TODO: send 0x04 capture-stop (ignore errors), reset the device, drop the session. */
}

/* ------------------------------------------------------------------- actions -- */

static void
dev_enroll (FpDevice *device)
{
  g_set_error_literal (fpi_device_get_enroll_data (device, NULL), FP_DEVICE_ERROR,
                       FP_DEVICE_ERROR_NOT_SUPPORTED,
                       "vcsfw enrollment: TODO (see docs/01-wire-format.md, 0x69/0x6b)");
}

static void
dev_verify (FpDevice *device)
{
  g_set_error_literal (fpi_device_get_verify_data (device, NULL), FP_DEVICE_ERROR,
                       FP_DEVICE_ERROR_NOT_SUPPORTED, "vcsfw verify: TODO (0x5e/0x60/0x62)");
}

static void
dev_identify (FpDevice *device)
{
  g_set_error_literal (fpi_device_get_identify_data (device, NULL), FP_DEVICE_ERROR,
                       FP_DEVICE_ERROR_NOT_SUPPORTED, "vcsfw identify: TODO");
}

static void
dev_list (FpDevice *device)
{
  g_set_error_literal (fpi_device_get_list_data (device, NULL), FP_DEVICE_ERROR,
                       FP_DEVICE_ERROR_NOT_SUPPORTED, "vcsfw list: TODO");
}

/* ---------------------------------------------------------------------- init -- */

static void
fpi_device_vcsfw_init (FpiDeviceVcsfw *self)
{
  (void) self;
}

static void
fpi_device_vcsfw_class_init (FpiDeviceVcsfwClass *klass)
{
  FpDeviceClass *dev_class = FP_DEVICE_CLASS (klass);

  dev_class->id = "vcsfw";
  dev_class->full_name = "Validity/Synaptics VCSFW";
  dev_class->type = FP_DEVICE_TYPE_USB;
  dev_class->id_table = (const FpIdEntry[]) {
    { .vid = 0x06cb, .pid = 0x009a },
    { .vid = 0, .pid = 0 },
  };

  dev_class->scan_type = FP_SCAN_TYPE_PRESS;

  dev_class->open = dev_open;
  dev_class->close = dev_close;
  dev_class->enroll = dev_enroll;
  dev_class->verify = dev_verify;
  dev_class->identify = dev_identify;
  dev_class->list = dev_list;
}

/* TOD entry point */
GType
fpi_tod_shared_driver_get_type (void)
{
  return fpi_device_vcsfw_get_type ();
}
