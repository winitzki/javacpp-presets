/*
 * Copyright (C) 2017 by A.
 *
 * Licensed either under the Apache License, Version 2.0, or (at your option)
 * under the terms of the GNU General Public License as published by
 * the Free Software Foundation (subject to the "Classpath" exception),
 * either version 2, or any later version (collectively, the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *     http://www.gnu.org/licenses/
 *     http://www.gnu.org/software/classpath/license.html
 *
 * or as provided in the LICENSE.txt file that accompanied this code.
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.bytedeco.javacpp.presets;

import org.bytedeco.javacpp.annotation.Platform;
import org.bytedeco.javacpp.annotation.Properties;
import org.bytedeco.javacpp.tools.Info;
import org.bytedeco.javacpp.tools.InfoMap;
import org.bytedeco.javacpp.tools.InfoMapper;

@Properties(target="org.bytedeco.javacpp.djvulibre", value={
    @Platform(include={"libdjvu/ddjvuapi.h"}, // "libdjvu/miniexp.h"},
                               link={"djvulibre@.21"}),
    @Platform(value="android", link={"djvulibre"}),
    @Platform(value="windows", preload={"libdjvulibre-21"}) })
public class djvulibre implements InfoMapper {
    // pattern: `typedef struct blah_s *blah_t`
    private void addStructStarTypedef(InfoMap infoMap, String structName, String typedefName, String javaName) {
        infoMap.put(new Info(typedefName).valueTypes(typedefName).pointerTypes("Pointer").cppNames(typedefName).javaNames(javaName));
        infoMap.put(new Info(structName).pointerTypes(typedefName));
    }

    // pattern: `typedef struct blah_s {...} blah_t`
    private void addStructTypedef(InfoMap infoMap, String structName, String typedefName, String javaName) {
//        infoMap.put(new Info(typedefName, structName).valueTypes(typedefName));
        infoMap.put(new Info(structName).pointerTypes(typedefName));
    }

    public void map(InfoMap infoMap) {
        infoMap.put(new Info("__cplusplus").define())
               .put(new Info("INFINITY", "defined(HUGE_VAL)", "NAN", "defined(INFINITY)").define(false))
               // C++ files have a no-op #define such as DDJVUAPI3
               .put(new Info("DDJVUAPI", "__BEGIN_DECLS", "__END_DECLS", "INLINE_DECL", "INLINE_FUN", "MINILISPAPI", "CBLAS_INDEX").cppTypes().annotations());
               // typedef struct blah_s * blah_t
               addStructStarTypedef(infoMap, "miniexp_s", "miniexp_t", "MiniExp");
               addStructStarTypedef(infoMap, "ddjvu_context_s", "ddjvu_context_s", "DDjVuContext");
               addStructTypedef(infoMap, "ddjvu_message_any_s", "ddjvu_message_any_t", "DDjVuMessageAny");
               addStructTypedef(infoMap, "ddjvu_message_error_s", "ddjvu_message_error_s", "DDjVuMessageError");

//               addStructStarTypedef(infoMap, "", "", "");
//               addStructStarTypedef(infoMap, "", "", "");
//               addStructStarTypedef(infoMap, "", "", "");
//               addStructStarTypedef(infoMap, "", "", "");
//               addStructStarTypedef(infoMap, "", "", "");
//               addStructStarTypedef(infoMap, "", "", "");
               // C++ files use these types within an optional #define, which cannot be automatically determined when javacpp creates the Java API.
               // So, they need to be skipped explicitly here.
               infoMap.put(new Info("GP", "DjVuDocument", "DjVuImage",
                             "ddjvu_get_DjVuDocument", "ddjvu_get_DjVuImage", "gsl_bspline_deriv_free", "gsl_multifit_fdfsolver_dif_fdf").skip());
    }
}
