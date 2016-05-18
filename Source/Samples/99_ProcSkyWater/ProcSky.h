/**
  @class ProcSky
  @brief Procedural Sky component for Urho3D
  @author carnalis <carnalis.j@gmail.com>
  @license MIT License
  @copyright
  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.
*/

#define PROCSKY_UI
//#define PROCSKY_TEXTURE_DUMPING

#pragma once
#include "../Scene/Component.h"
#include "../Graphics/Camera.h"
#include "../Scene/Node.h"
#include "../Graphics/RenderPath.h"
#include "../Graphics/Viewport.h"
#include "../Container/Vector.h"
#include "../Math/Matrix3.h"
#include "../Math/Vector3.h"
using namespace Urho3D;

namespace Urho3D {
class Skybox;
class StringHash;
#if defined(PROCSKY_UI)
class UIElement;
#endif
#if defined(PROCSKY_TEXTURE_DUMPING)
class Texture2D;
class TextureCube;
#endif
}

class ProcSky: public Component {
  URHO3D_OBJECT(ProcSky, Component);

public:
  ProcSky(Context* context);
  virtual ~ProcSky();
  static void RegisterObject(Context* context);
  void OnNodeSet(Node* node);

  /// Automatic update renders according to update interval. If Manual, user calls Update() to render.
  void SetUpdateAuto(bool updateAuto);
  bool GetUpdateAuto() const { return updateAuto_; }
  /// Set the rendering interval (default 0).
  void SetUpdateInterval(float interval) { updateInterval_ = interval; }
  float GetUpdateInterval() const { return updateInterval_; }
  float GetUpdateWait() const { return updateWait_; }
  /// Set size of Skybox TextureCube.
  bool SetRenderSize(unsigned size);
  unsigned GetRenderSize() const { return renderSize_; }
  /// Initialize objects and subscribe to update events.
  bool Initialize();
  /// Queue render of next frame.
  void Update();

protected:
  void HandleUpdate(StringHash eventType, VariantMap& eventData);
  /// Set rendering of next frame active/inactive.
  void SetRenderQueued(bool enable);
  void HandlePostRenderUpdate(StringHash eventType, VariantMap& eventData);

#if defined(PROCSKY_UI)
  void HandleKeyDown(StringHash eventType, VariantMap& eventData);
  void ToggleUI();
  void CreateSlider(UIElement* parent, const String& label, float* target, float range);
  void HandleSliderChanged(StringHash eventType, VariantMap& eventData);
#endif

#if defined(PROCSKY_TEXTURE_DUMPING)
  void DumpTexCubeImages(TextureCube* texCube, const String& filePathPrefix);
  void DumpTexture(Texture2D* texture, const String& filePath);
#endif

protected:
  /// Camera used for face projections.
  Camera* cam_;
  /// Urho3D Skybox with geometry and main TextureCube.
  SharedPtr<Skybox> skybox_;
  /// Node used for light direction.
  WeakPtr<Node> lightNode_;
  SharedPtr<RenderPath> rPath_;
  /// Render size of each face.
  unsigned renderSize_;
  /// FOV used to initialize the default camera. Can adjust for Skybox seams.
  float renderFOV_;
  /// Fixed rotations for each cube face.
  Matrix3 faceRotations_[MAX_CUBEMAP_FACES];

  bool updateAuto_;
  float updateInterval_;
  float updateWait_;
  bool renderQueued_;
#if defined(PROCSKY_UI)
  Vector3 angVel_;
#endif
  /// Atmospheric parameters.
  Vector3 Kr_; // Absorption profile of air.
  float rayleighBrightness_;
  float mieBrightness_;
  float spotBrightness_;
  float scatterStrength_;
  float rayleighStrength_;
  float mieStrength_;
  float rayleighCollectionPower_;
  float mieCollectionPower_;
  float mieDistribution_;
};
