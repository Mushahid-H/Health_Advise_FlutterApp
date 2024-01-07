import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthCare App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => SymptomsScreen(),
        '/bmi': (context) => BMIScreen(),
        '/first_aid': (context) => FirstAidScreen(),
      },
    );
  }
}

class SymptomsScreen extends StatefulWidget {
  @override
  _SymptomsScreenState createState() => _SymptomsScreenState();
}

class _SymptomsScreenState extends State<SymptomsScreen> {
  TextEditingController _symptomsController = TextEditingController();
  List<String> _suggestedDiseases = [];
  Map<String, List<String>> _suggestedMedications = {};
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Health Advisor',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                  'https://images.pexels.com/photos/3786215/pexels-photo-3786215.jpeg'),
              fit: BoxFit.fill,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _symptomsController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Symptoms',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    final String symptoms = _symptomsController.text;
                    // Simulate fetching data from OpenAI API
                    await Future.delayed(Duration(seconds: 2));
                    setState(() {
                      _suggestedDiseases = _suggestDiseases(symptoms);
                      _suggestedMedications =
                          _suggestMedications(_suggestedDiseases);
                    });
                  },
                  child: Text('Get Medical Suggestions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16.0),
                if (_suggestedDiseases.isNotEmpty || counter++ == 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Suggested Diseases:',
                        style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo),
                      ),
                      Wrap(
                        spacing: 8.0,
                        children: _suggestedDiseases
                            .map(
                              (disease) => Chip(
                                label: Text(disease,
                                    style: const TextStyle(
                                      color: Colors.white,
                                    )),
                                backgroundColor: Colors.blue,
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 16.0),
                      if (_suggestedMedications.isNotEmpty || counter++ == 1)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Suggested Medications:',
                              style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _suggestedMedications.entries
                                  .map(
                                    (entry) => Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${entry.key}: ${entry.value.join(", ")}',
                                          style: const TextStyle(
                                              fontSize: 16.0,
                                              color: Colors.indigo),
                                        ),
                                        const SizedBox(height: 8.0),
                                      ],
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: 16.0),
                          ],
                        )
                      else
                        const Text(
                          'No matching medications found.',
                          style:
                              TextStyle(fontSize: 18.0, color: Colors.indigo),
                        ),
                    ],
                  )
                else
                  const Text(
                    'No matching diseases found. Please try again.',
                    style: TextStyle(fontSize: 18.0, color: Colors.indigo),
                  ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/bmi');
                  },
                  child: Text('Calculate BMI'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/first_aid');
                  },
                  child: Text('First Aid Guide'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<String> _suggestDiseases(String symptoms) {
    symptoms = symptoms.toLowerCase();
    List<String> suggestedDiseases = [];

    for (String symptom in symptomDiseaseMapping.keys) {
      if (symptoms.contains(symptom)) {
        suggestedDiseases.addAll(symptomDiseaseMapping[symptom]!);
      }
    }

    // Remove duplicate diseases
    return suggestedDiseases.toSet().toList();
  }

  Map<String, List<String>> _suggestMedications(List<String> diseases) {
    Map<String, List<String>> medications = {};

    for (String disease in diseases) {
      List<String> associatedMedications =
          medicationRecommendation[disease] != null
              ? [medicationRecommendation[disease]!['Medication']!]
              : [];
      medications[disease] = associatedMedications;
    }

    return medications;
  }
}

class BMIScreen extends StatefulWidget {
  @override
  _BMIScreenState createState() => _BMIScreenState();
}

class _BMIScreenState extends State<BMIScreen> {
  TextEditingController _heightController = TextEditingController();
  TextEditingController _weightController = TextEditingController();
  double _bmiResult = 0.0;
  String _bmiCategory = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BMI Calculator',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                  'https://images.pexels.com/photos/3786215/pexels-photo-3786215.jpeg'),
              fit: BoxFit.fill,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Enter Height (in cm)',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Enter Weight (in kg)',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    _calculateBMI();
                  },
                  child: Text('Calculate BMI'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16.0),
                _bmiResult != 0.0 ? _buildBMIResultCard() : Container(),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBMIResultCard() {
    return Card(
      color: Colors.blue.withOpacity(0.8),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'BMI: $_bmiResult',
              style: const TextStyle(
                fontSize: 18.0,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              _bmiCategory,
              style: const TextStyle(
                fontSize: 30.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _calculateBMI() {
    double height = double.tryParse(_heightController.text) ?? 0.0;
    double weight = double.tryParse(_weightController.text) ?? 0.0;

    if (height > 0 && weight > 0) {
      double heightInMeters = height / 100.0;
      double bmi = weight / (heightInMeters * heightInMeters);

      setState(() {
        _bmiResult = double.parse(bmi.toStringAsFixed(2));
        _bmiCategory = _getBMICategory(bmi);
      });
    }
  }
}

// Inside the build method of FirstAidScreen class
// Inside the build method of FirstAidScreen class
class FirstAidScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'First Aid Guide',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
                'https://images.pexels.com/photos/3786215/pexels-photo-3786215.jpeg'),
            fit: BoxFit.fill,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: const [
              FirstAidItem(
                title: 'CPR (Cardiopulmonary Resuscitation)',
                description:
                    'Perform CPR if the person is unconscious and not breathing. Call emergency services first.',
              ),
              FirstAidItem(
                title: 'Choking',
                description:
                    'For conscious adults and children, perform abdominal thrusts. For unconscious individuals, start CPR.',
              ),
              FirstAidItem(
                title: 'Bleeding',
                description:
                    'Apply direct pressure to the wound using a clean cloth or bandage. Elevate the affected limb if possible.',
              ),
              FirstAidItem(
                title: 'Burns',
                description:
                    'For minor burns, cool the affected area with cold water. Do not use ice. For severe burns, seek immediate medical attention.',
              ),
              FirstAidItem(
                title: 'Fractures',
                description:
                    'Immobilize the injured area using a splint. Do not try to realign the bones. Seek medical help.',
              ),
              FirstAidItem(
                title: 'Seizures',
                description:
                    'Stay calm and clear the area around the person. Place the person on their side after the seizure stops. Seek medical attention if it lasts longer than 5 minutes.',
              ),
              FirstAidItem(
                title: 'Allergic Reactions',
                description:
                    'Administer an epinephrine auto-injector (if available) for severe reactions. Call emergency services.',
              ),
              FirstAidItem(
                title: 'Poisoning',
                description:
                    'Call the Poison Control Center immediately. Provide information about the substance ingested. Do not induce vomiting without professional advice.',
              ),
              // Add more FirstAidItem widgets here
            ],
          ),
        ),
      ),
    );
  }
}

class FirstAidItem extends StatelessWidget {
  final String title;
  final String description;

  const FirstAidItem({
    Key? key,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.withOpacity(0.8),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 8.0),
            Text(
              description,
              style: const TextStyle(fontSize: 16.0, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

String _getBMICategory(double bmi) {
  if (bmi < 18.5) {
    return 'Underweight';
  } else if (bmi >= 18.5 && bmi < 24.9) {
    return 'Normal Weight';
  } else if (bmi >= 25.0 && bmi < 29.9) {
    return 'Overweight';
  } else {
    return 'Obese';
  }
}

// Your symptomDiseaseMapping and medicationRecommendation maps go here

Map<String, Map<String, String>> medicationRecommendation = {
  'Migraine': {'Medication': 'Triptans (e.g., sumatriptan), NSAIDs'},
  'Tension Headache': {
    'Medication':
        'Over-the-counter pain relievers (e.g., acetaminophen, ibuprofen)'
  },
  'Influenza (Flu)': {
    'Medication': 'Antiviral medications (e.g., oseltamivir)'
  },
  'Hypertension': {
    'Medication':
        'Antihypertensive medications (e.g., ACE inhibitors, beta-blockers)'
  },
  'Vertigo': {
    'Medication': 'Antivertigo medications (e.g., meclizine), physical therapy'
  },
  'Dehydration': {'Medication': 'Rehydration solutions'},
  'Anxiety Disorders': {'Medication': 'Anxiolytics (e.g., lorazepam)'},
  'Chronic Fatigue Syndrome (CFS)': {
    'Medication': 'Symptomatic treatment, lifestyle modifications'
  },
  'Depression': {'Medication': 'Antidepressants (e.g., SSRIs, SNRIs)'},
  'Diabetes (Type 2)': {
    'Medication': 'Oral antidiabetic medications (e.g., metformin), insulin'
  },
  'Thyroid Disorders': {
    'Medication': 'Thyroid hormone replacement (e.g., levothyroxine)'
  },
  'Chronic Kidney Disease (CKD)': {
    'Medication': 'Management of underlying causes, supportive care'
  },
  'Coronary Artery Disease (CAD)': {
    'Medication': 'Nitroglycerin, beta-blockers, aspirin'
  },
  'Chronic Obstructive Pulmonary Disease (COPD)': {
    'Medication': 'Bronchodilators, inhaled corticosteroids'
  },
  'Asthma': {'Medication': 'Inhaled corticosteroids, bronchodilators'},
  'Gastroenteritis': {
    'Medication': 'Symptomatic relief, antiemetics, rehydration solutions'
  },
  'Arthritis (Rheumatoid or Osteoarthritis)': {
    'Medication': 'NSAIDs, DMARDs, corticosteroids'
  },
  'Alzheimer\'s Disease': {
    'Medication': 'Cholinesterase inhibitors (e.g., donepezil), memantine'
  },
  'Hypothyroidism': {
    'Medication': 'Levothyroxine (thyroid hormone replacement)'
  },
  'Muscle Strain': {
    'Medication': 'Rest, Pain relievers (e.g., acetaminophen, ibuprofen)'
  },
  'Herniated Disc': {
    'Medication':
        'Physical therapy, Muscle relaxants, Pain relievers (e.g., ibuprofen)'
  },
  'Concussion': {'Medication': 'Rest, Pain relievers (e.g., acetaminophen)'},
  'Transient Global Amnesia': {'Medication': 'No specific medication'},
  'Gastritis': {
    'Medication':
        'Antacids, Proton pump inhibitors (e.g., omeprazole), H2 blockers (e.g., ranitidine)'
  },
  'Appendicitis': {'Medication': 'Surgery (Appendectomy)'},
  'Unknown': {
    'Medication': 'No specific medication recommendation for this disease'
  },

  // Additional diseases
  'Insomnia': {'Medication': 'Sleep hygiene, Cognitive behavioral therapy'},
  'Bipolar Disorder': {'Medication': 'Mood stabilizers (e.g., lithium)'},
  'Syncope': {'Medication': 'Depends on underlying cause'},
  'Epilepsy': {'Medication': 'Antiepileptic drugs (e.g., carbamazepine)'},
  'Peripheral Neuropathy': {
    'Medication': 'Pain relievers, Antidepressants, Antiseizure medications'
  },
  'Glaucoma': {'Medication': 'Eyedrops (e.g., prostaglandins)'},
  'Irritable Bowel Syndrome (IBS)': {
    'Medication': 'Dietary changes, Antispasmodic medications'
  },
  'Dysphagia': {'Medication': 'Treatment of underlying cause'},
  'Eczema': {'Medication': 'Topical corticosteroids, Moisturizers'},
  'Diabetes Insipidus': {
    'Medication': 'Desmopressin, Thiazide diuretics',
  },
  'Attention Deficit Hyperactivity Disorder (ADHD)': {
    'Medication':
        'Stimulants (e.g., methylphenidate), Non-stimulants (e.g., atomoxetine)'
  },
  'Common Cold': {
    'Medication': 'Rest, Hydration, Over-the-counter cold remedies'
  },
  'Flu': {'Medication': 'Antiviral medications, Rest, Hydration'},
  'Strep Throat': {
    'Medication':
        'Antibiotics (e.g., penicillin), Pain relievers (e.g., acetaminophen)'
  },
};
Map<String, List<String>> symptomDiseaseMapping = {
  'headache': ['Migraine', 'Tension Headache', 'Hypertension'],
  'dizziness': ['Vertigo', 'Dehydration', 'Migraine', 'Anxiety Disorders'],
  'fatigue': ['Chronic Fatigue Syndrome (CFS)', 'Depression'],
  'Flu': ['Influenza (Flu)', 'Flu'],
  'increased thirst': ['Diabetes (Type 2)'],
  'frequent urination': ['Diabetes (Type 2)'],
  'unexplained weight loss': ['Diabetes (Type 2)', 'Hyperthyroidism'],
  'chest pain': ['Coronary Artery Disease (CAD)'],
  'shortness of breath': [
    'Coronary Artery Disease (CAD)',
    'Chronic Obstructive Pulmonary Disease (COPD)',
    'Asthma'
  ],
  'chronic cough': [
    'Chronic Obstructive Pulmonary Disease (COPD)',
    'Asthma',
    'Gastroesophageal Reflux Disease (GERD)'
  ],
  'nausea': ['Migraine', 'Coronary Artery Disease (CAD)', 'Gastroenteritis'],
  'sweating': ['Coronary Artery Disease (CAD)'],
  'joint pain': ['Arthritis (Rheumatoid or Osteoarthritis)'],
  'swelling': ['Arthritis (Rheumatoid or Osteoarthritis)'],
  'stiffness': ['Arthritis (Rheumatoid or Osteoarthritis)'],
  'persistent sad': ['Depression'],
  'loss of interest': ['Depression'],
  'changes in appetite': ['Depression'],
  'suicidal thoughts': ['Depression'],

  'excessive worry': ['Anxiety Disorders'],
  'restlessness': ['Anxiety Disorders'],
  'muscle tension': ['Anxiety Disorders'],
  'irritability': ['Anxiety Disorders'],
  'memory loss': ['Alzheimer\'s Disease'],
  'confusion': ['Alzheimer\'s Disease'],
  'difficulty completing tasks': ['Alzheimer\'s Disease'],
  'changes in mood': ['Alzheimer\'s Disease'],
  'diarrhea': ['Gastroenteritis'],
  'vomiting': ['Gastroenteritis'],
  'abdominal cramps': ['Gastroenteritis'],
  'fever': ['Influenza (Flu)', 'Gastroenteritis'],
  'cold intolerance': ['Hypothyroidism'],
  'dry skin': ['Hypothyroidism'],
  'hair loss': ['Hypothyroidism'],
  'weight loss': ['Hyperthyroidism'],
  'rapid heart rate': ['Hyperthyroidism'],
  'anxiety': ['Hyperthyroidism'],
  'excessive sweating': ['Hyperthyroidism'],
  'tremors': ['Hyperthyroidism'],
  'back pain': ['Muscle Strain', 'Herniated Disc'],
  'short-term memory loss': ['Concussion', 'Transient Global Amnesia'],
  'abdominal pain': ['Gastritis', 'Appendicitis'],
  'Unknown': ['Unknown'],

  // Additional diseases
  'sleeplessness': ['Insomnia'],
  'insomnia': ['Insomnia'],
  'sleep problems': ['Insomnia'],
  'mood swings': ['Bipolar Disorder'],
  'fainting': ['Syncope'],
  'seizures': ['Epilepsy'],
  'numbness': ['Peripheral Neuropathy'],
  'blurred vision': ['Glaucoma'],
  'digestive issues': ['Irritable Bowel Syndrome (IBS)'],
  'difficulty swallowing': ['Dysphagia'],
  'skin rash': ['Eczema'],
  'excessive thirst': ['Diabetes Insipidus'],

  'chest tightness': ['Asthma', 'Coronary Artery Disease (CAD)'],
  'dry cough': ['Chronic Obstructive Pulmonary Disease (COPD)', 'Asthma'],
  'abdominal bloating': ['Irritable Bowel Syndrome (IBS)'],
  'constipation': ['Irritable Bowel Syndrome (IBS)'],
  'diarrhea alternating with constipation': ['Irritable Bowel Syndrome (IBS)'],
  'difficulty focusing': ['Attention Deficit Hyperactivity Disorder (ADHD)'],
  'hyperactivity': ['Attention Deficit Hyperactivity Disorder (ADHD)'],
  'persistent itching': ['Eczema', 'Allergic Reaction'],
  'sore throat': ['Common Cold', 'Flu', 'Strep Throat'],
  'runny nose': ['Common Cold', 'Flu'],
};
