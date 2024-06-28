import 'package:flutter/material.dart';
import 'package:integrand/consts.dart';
import 'package:integrand/helpers/page_animation.dart';
import 'package:integrand/schedule.dart';
import 'backend/data_storage.dart';
import 'backend/studentvue_api.dart';
import 'package:provider/provider.dart';
import 'package:integrand/loading_schedule.dart';

class IntakeCredentials extends StatefulWidget {
  const IntakeCredentials({super.key});

  @override
  State<IntakeCredentials> createState() => _IntakeCredentials();
}

class _IntakeCredentials extends State<IntakeCredentials> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
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
          const Padding(
            padding: EdgeInsets.only(left: 30.0, right: 30.0),
            child: CredentialsForm(),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 30.0,
                  right: 30.0,
                  bottom: 30.0
                ),
                child: TextButton(
                  style: buttonStyle,
                  onPressed: () {
                    // Submit credentials form
                    // DataStorage.saveData(),
                    Provider.of<StudentVueAPI>(context, listen: false).initialize(
                      'https://parent-portland.cascadetech.org/portland',
                      username,
                      password,
                    );
                    animateWithSlideFromRight(context, const Schedule(), Durations.medium2);
                  },
                  child: const Text(
                    "Continue",
                    style: bodyStyle,
                  )
                ),
              ),
            ),
          ),
        ],
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
            style: titleStyleWithGradient,
          ),
          const TextSpan(
            text: " Information",
            style: titleStyle,
          ),
        ],
      )
    );
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
  const CredentialsForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          style: bodyStyle,
          decoration: InputDecoration(
            labelText: "Username",
            labelStyle: bodyStyleSubdued,
          ),
          onSubmitted: (value) => {
            username = value,
          },
        ),
        const SizedBox(
          height: 20.0,
        ),
        TextField(
          style: bodyStyle,
          obscureText: true,
          decoration: InputDecoration(
            labelText: "Password",
            labelStyle: bodyStyleSubdued,
          ),
          onSubmitted: (value) => {
            password = value,
          },
        ),
        const SizedBox(
          height: 20.0,
        ),
      ],
    );
  }
}
