structure template hardware/nic/deprecation-warning;

'type' = { deprecated(0, format('%s %s',
    'Use of nic templates immediately under hardware/nic/ is deprecated.',
    'Please use templates under hardware/nic/nic_manufacturer/ instead.')); 'deprecated' };
