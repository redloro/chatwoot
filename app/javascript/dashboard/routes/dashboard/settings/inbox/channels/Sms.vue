<template>
  <div
    class="border border-slate-25 dark:border-slate-800/60 bg-white dark:bg-slate-900 h-full p-6 w-full max-w-full md:w-3/4 md:max-w-[75%] flex-shrink-0 flex-grow-0"
  >
    <page-header
      :header-title="$t('INBOX_MGMT.ADD.SMS.TITLE')"
      :header-content="$t('INBOX_MGMT.ADD.SMS.DESC')"
    />
    <div class="w-[65%] flex-shrink-0 flex-grow-0 max-w-[65%]">
      <label>
        {{ $t('INBOX_MGMT.ADD.SMS.PROVIDERS.LABEL') }}
        <select v-model="provider">
          <option value="default">
            {{ $t('INBOX_MGMT.ADD.SMS.PROVIDERS.BANDWIDTH') }}
          </option>
          <option value="dialpad">
            {{ $t('INBOX_MGMT.ADD.SMS.PROVIDERS.DIALPAD') }}
          </option>
          <option value="twilio">
            {{ $t('INBOX_MGMT.ADD.SMS.PROVIDERS.TWILIO') }}
          </option>
        </select>
      </label>
    </div>
    <twilio v-if="provider === 'twilio'" type="sms" />
    <dialpad-sms v-else-if="provider === 'dialpad'" />
    <bandwidth-sms v-else />
  </div>
</template>

<script>
import PageHeader from '../../SettingsSubPageHeader.vue';
import BandwidthSms from './BandwidthSms.vue';
import DialpadSms from './DialpadSms.vue';
import Twilio from './Twilio.vue';

export default {
  components: {
    PageHeader,
    BandwidthSms,
    DialpadSms,
    Twilio,
  },
  data() {
    return {
      provider: 'twilio',
    };
  },
};
</script>
