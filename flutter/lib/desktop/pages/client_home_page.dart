import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hbb/common.dart';
import 'package:flutter_hbb/models/state_model.dart';
import 'package:flutter_hbb/desktop/widgets/scroll_wrapper.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';
import 'package:provider/provider.dart';
import 'package:auto_size_text/auto_size_text.dart';

class ClientHomePage extends StatefulWidget {
  const ClientHomePage({Key? key}) : super(key: key);

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    // Ensure window size is correct for client mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      windowManager.setSize(const Size(360, 600));
      windowManager.setMinimumSize(const Size(360, 500));
    });
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Powered By
                const Opacity(
                  opacity: 0.6,
                  child: Text(
                    "Powered by Adaa.store",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Logo
                Image.asset(
                  'assets/logo.png',
                  width: 80,
                  height: 80,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.shield, size: 80, color: MyTheme.accent);
                  },
                ),
                const SizedBox(height: 30),

                // Title & Description
                Text(
                  translate("Your Desktop"),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  translate("Your desktop can be accessed with this ID and password."),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 30),

                // ID Board
                _buildIDBoard(context),
                const SizedBox(height: 10),
                
                // Password Board
                _buildPasswordBoard(context),
                
                const Spacer(),

                // Quit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      foregroundColor: Colors.red, // Red text for Quit
                      side: BorderSide(color: Colors.grey[300]!),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      windowManager.close();
                    },
                    child: Text(
                      translate("Quit"),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Status
                const Divider(),
                const SizedBox(height: 10),
                OnlineStatusWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIDBoard(BuildContext context) {
    final model = gFFI.serverModel;
    return ChangeNotifierProvider.value(
      value: model,
      child: Consumer<ServerModel>(
        builder: (context, model, child) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            height: 57,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Container(
                  width: 3,
                  decoration: const BoxDecoration(color: MyTheme.accent),
                ).marginOnly(top: 5),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          translate("ID"),
                          style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.color
                                  ?.withOpacity(0.5)),
                        ).marginOnly(top: 5),
                        Flexible(
                          child: GestureDetector(
                            onDoubleTap: () {
                              Clipboard.setData(
                                  ClipboardData(text: model.serverId.text));
                              showToast(translate("Copied"));
                            },
                            child: TextFormField(
                              controller: model.serverId,
                              readOnly: true,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.only(top: 10, bottom: 10),
                              ),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPasswordBoard(BuildContext context) {
    final model = gFFI.serverModel;
    return ChangeNotifierProvider.value(
      value: model,
      child: Consumer<ServerModel>(
        builder: (context, model, child) {
          RxBool refreshHover = false.obs;
          final textColor = Theme.of(context).textTheme.titleLarge?.color;
          final showOneTime = model.approveMode != 'click' &&
              model.verificationMethod != kUsePermanentPassword;
              
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Container(
                  width: 3,
                  height: 52,
                  decoration: const BoxDecoration(color: MyTheme.accent),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          translate("One-time Password"),
                          style: TextStyle(
                              fontSize: 14, color: textColor?.withOpacity(0.5)),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onDoubleTap: () {
                                  if (showOneTime) {
                                    Clipboard.setData(
                                        ClipboardData(text: model.serverPasswd.text));
                                    showToast(translate("Copied"));
                                  }
                                },
                                child: TextFormField(
                                  controller: model.serverPasswd,
                                  readOnly: true,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.only(top: 14, bottom: 10),
                                  ),
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                            if (showOneTime)
                              AnimatedRotationWidget(
                                onPressed: () => bind.mainUpdateTemporaryPassword(),
                                child: Tooltip(
                                  message: translate('Refresh Password'),
                                  child: Obx(() => RotatedBox(
                                      quarterTurns: 2,
                                      child: Icon(
                                        Icons.refresh,
                                        color: refreshHover.value
                                            ? textColor
                                            : const Color(0xFFDDDDDD),
                                        size: 22,
                                      ))),
                                ),
                                onHover: (value) => refreshHover.value = value,
                              ).marginOnly(right: 8, top: 4),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
