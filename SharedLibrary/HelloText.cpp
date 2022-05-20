//
// Copyright (c) 2022 Glauco Pacheco <glauco@cuteserver.io>
// All rights reserved
//

#include "HelloText.h"
#include "../StaticLibrary/HelloTextInternal.h"


QString HelloText::getText()
{
    return HelloTextInternal::getText();
}
