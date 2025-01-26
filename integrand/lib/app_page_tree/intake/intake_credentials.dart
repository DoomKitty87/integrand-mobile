import 'package:flutter/material.dart';
import 'package:integrand/consts.dart';
import 'package:integrand/main.dart';
import '../../backend/data_storage.dart';
import '../../backend/studentvue_api/studentvue_api.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class IntakeCredentials extends StatefulWidget {
  const IntakeCredentials({super.key});

  @override
  State<IntakeCredentials> createState() => _IntakeCredentials();
}

class _IntakeCredentials extends State<IntakeCredentials> {
  bool _nullCredsBool = false;
  bool _invalidCredsBool = false;

  bool _obscureText = true;

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AppBackground(
        child: Column(
          children: [
            const SizedBox(
              height: 100.0,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 30.0, right: 30.0),
              child: AddInformationTitle(),
            ),
            const SizedBox(
              height: 50.0,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 30.0, right: 30.0),
              child: CredentialsDescription(),
            ),
            const SizedBox(
              height: 50.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: CredentialsForm(
                  obscureText: _obscureText, showButtonCallback: _toggle),
            ),
            const SizedBox(
              height: 40.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: ErrorText(
                message: _nullCredsBool
                    ? "Please enter your username and password."
                    : _invalidCredsBool
                        ? "Invalid username or password."
                        : "",
              ),
            ),
            const SizedBox(
              height: 60.0,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 30.0, right: 30.0),
              child: CredentialsSafetyMessage(),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 30.0, right: 30.0, bottom: 30.0),
                  child: TextButton(
                    style: buttonStyle,
                    onPressed: () async {
                      if (StudentVueAPI.credsAreNull(username, password)) {
                        // Show error message
                        setState(() {
                          _nullCredsBool = true;
                          _invalidCredsBool = false;
                        });
                      }
                      // TODO: remove the hard coded url
                      else if (await StudentVueAPI.credsAreInvalid(
                          username,
                          password,
                          'https://parent-portland.cascadetech.org/portland')) {
                        // Show error message
                        setState(() {
                          _nullCredsBool = false;
                          _invalidCredsBool = true;
                        });
                      } else {
                        // Submit credentials form
                        await DataStorage.saveData();
                        // Trigger rebuild of main App widget
                        if (!context.mounted) return;
                        Provider.of<AppData>(context, listen: false)
                            .setIntake(true);
                        // animateWithSlideFromRight(context, const LoadingSchedule(), Durations.medium2);
                      }
                    },
                    child: const Text(
                      "Continue",
                      style: bodyStyle,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddInformationTitle extends StatelessWidget {
  const AddInformationTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
        text: TextSpan(
      children: <TextSpan>[
        const TextSpan(
          text: "Add ",
          style: titleStyle,
        ),
        TextSpan(
          text: "School",
          style: titleStyleGradient,
        ),
        const TextSpan(
          text: " Information",
          style: titleStyle,
        ),
      ],
    ));
  }
}

class CredentialsDescription extends StatelessWidget {
  const CredentialsDescription({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      "Integrand uses your information to access StudentVUE and Canvas to show your grades and upcoming assignments.",
      style: bodyStyle,
    );
  }
}

class CredentialsForm extends StatelessWidget {
  const CredentialsForm(
      {super.key, required this.obscureText, required this.showButtonCallback});

  final bool obscureText;
  final Function showButtonCallback;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          style: bodyStyle,
          autocorrect: false,
          cursorColor: purpleGradient,
          decoration: InputDecoration(
            labelText: "Username (without @domain.com)",
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: purpleGradient),
            ),
            labelStyle: bodyStyleSubdued,
          ),
          onChanged: (value) => {username = value},
        ),
        const SizedBox(
          height: 20.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 9,
              child: TextFormField(
                autocorrect: false,
                enableSuggestions: false,
                style: bodyStyle,
                cursorColor: purpleGradient,
                decoration: InputDecoration(
                  labelText: 'Password',
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: purpleGradient),
                  ),
                  labelStyle: bodyStyleSubdued,
                ),
                obscureText: obscureText,
                onChanged: (value) {
                  password = value;
                },
              ),
            ),
            Expanded(
              flex: 1,
              child: IconButton(
                icon: Icon((obscureText)
                    ? Icons.remove_red_eye_outlined
                    : Icons.remove_red_eye),
                onPressed: () {
                  showButtonCallback();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class CredentialsSafetyMessage extends StatelessWidget {
  const CredentialsSafetyMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: "Your information will ",
            style: bodyStyle,
          ),
          TextSpan(
            text: "never",
            style: bodyStyleBold,
          ),
          TextSpan(
            text: " be sold or shared with third parties.",
            style: bodyStyle,
          ),
        ],
      ),
    );
  }
}

class ErrorText extends StatelessWidget {
  const ErrorText({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: errorStyle,
    ).animate(
      target: 1,
      effects: [const FadeEffect()]
    );
  }
}
