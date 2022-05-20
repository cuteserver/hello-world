//
// Copyright (c) 2022 Glauco Pacheco <glauco@cuteserver.io>
// All rights reserved
//

#include "HelloTextInternal.h"


QString HelloTextInternal::getText()
{
#if defined(APPLE_MACOSX)
    return {"Hello Cute World (macOS)."};
#elif defined(APPLE_IOS)
    return {"Hello Cute World (iOS)."};
#elif defined(UNIX)
    return {"Hello Cute World (UNIX)."};
#elif defined(WINDOWS)
    return {"Hello Cute World (Windows)."};
#elif defined(ANDROID_ARMEABI_V7A)
    return {"Hello Cute World (Android armeabi-v7a)."};
#elif defined(ANDROID_ARM64_V8A)
    return {"Hello Cute World (Android arm64-v8a)."};
#elif defined(ANDROID_X86)
    return {"Hello Cute World (Android x86)."};
#elif defined(ANDROID_X86_64)
    return {"Hello Cute World (Android x86_64)."};
#else
#error "Unknown Platform"
#endif
}
