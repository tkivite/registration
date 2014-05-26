package org.openmrs.module.registrationapp;


import org.junit.Test;
import org.openmrs.module.registration.RegistrationActivator;
import org.openmrs.test.BaseModuleContextSensitiveTest;
import org.openmrs.test.SkipBaseSetup;

import static org.junit.Assert.assertNotNull;

@SkipBaseSetup
public class RegistrationAppActivatorComponentTest extends BaseModuleContextSensitiveTest{

    @Test
    public void testActivator() throws Exception{
        RegistrationActivator activator = new RegistrationActivator();
        assertNotNull(activator);
    }
}
