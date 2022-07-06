﻿// #wortmann {
// #4.2.03
// Добавляем вызов создания полей контрагента
// Галфинд Окунев 2022/07/05
&НаСервере
Процедура гф_ПриСозданииНаСервереПосле(Отказ, СтандартнаяОбработка)
	
	гф_СоздатьИЗаполнитьРеквизитыКонтрагента();
	
КонецПроцедуры// } #wortmann

// #wortmann {
// #4.2.03
// Добавляем вызов создания полей контрагента
// Галфинд Окунев 2022/07/05
&НаСервере
Процедура гф_ПриЧтенииНаСервереПеред(ТекущийОбъект)

	гф_СоздатьИЗаполнитьРеквизитыКонтрагента(ТекущийОбъект);
	
КонецПроцедуры// } #wortmann


// #wortmann {
// #4.2.03
// Добавляем поля контрагента если еще не созданы и заполняем, если контрагент существует
// Галфинд Окунев 2022/07/05
Процедура гф_СоздатьИЗаполнитьРеквизитыКонтрагента(ТекущийОбъект = Неопределено)
	
	Если Элементы.Найти("гф_ОсновнойКонтрагент") = Неопределено Тогда
		
		ДобавляемыеРеквизиты = Новый Массив;
		
		ДобавляемыеРеквизиты.Добавить(Новый РеквизитФормы("гф_Код",
		Новый ОписаниеТипов("Строка",,Новый КвалификаторыСтроки(10)),,
		"Код контрагента",Истина));
		
		ДобавляемыеРеквизиты.Добавить(Новый РеквизитФормы("гф_Контрагент",
		Новый ОписаниеТипов("СправочникСсылка.Контрагенты"),,
		"Контрагент",Истина));
		
		ДобавляемыеРеквизиты.Добавить(Новый РеквизитФормы("гф_ОсновнойКонтрагент",
		Новый ОписаниеТипов("СправочникСсылка.Контрагенты"),,
		"Основной контрагент",Истина));

		ДобавляемыеРеквизиты.Добавить(Новый РеквизитФормы("гф_Логистика",
		Новый ОписаниеТипов("Булево"),,
		"Логистика",Истина));
		
		ДобавляемыеРеквизиты.Добавить(Новый РеквизитФормы("гф_RC_GLN_номер",
		Новый ОписаниеТипов("Строка",,Новый КвалификаторыСтроки(13)),,
		"RC_GLN_номер",Истина));
		
		ДобавляемыеРеквизиты.Добавить(Новый РеквизитФормы("гф_Комментарий",
		Новый ОписаниеТипов("Строка",,Новый КвалификаторыСтроки(0)),,
		"Комментарий",Истина));
		
		ДобавляемыеРеквизиты.Добавить(Новый РеквизитФормы("гф_Зарегистрирован",
		Новый ОписаниеТипов("Булево"),,
		"Зарегистрирован",Истина));
		
		ДобавляемыеРеквизиты.Добавить(Новый РеквизитФормы("гф_АдресаДоставки",
		Новый ОписаниеТипов("ТаблицаЗначений"),,
		"Адреса доставки",Истина));   
		
		ДобавляемыеРеквизиты.Добавить(Новый РеквизитФормы("Адрес",
		Новый ОписаниеТипов("СправочникСсылка.гф_АдресаДоставки"),"гф_АдресаДоставки",
		"Адрес",Истина));   
		
		ДобавляемыеРеквизиты.Добавить(Новый РеквизитФормы("гф_ОтветственныйМенеджер",
		Новый ОписаниеТипов("ТаблицаЗначений"),,
		"Ответственный менеджер",Истина));   

		ДобавляемыеРеквизиты.Добавить(Новый РеквизитФормы("Организация",
		Новый ОписаниеТипов("СправочникСсылка.Организации"),"гф_ОтветственныйМенеджер",
		"Организация",Истина));   
		
		ДобавляемыеРеквизиты.Добавить(Новый РеквизитФормы("Пользователь",
		Новый ОписаниеТипов("СправочникСсылка.Пользователи"),"гф_ОтветственныйМенеджер",
		"Пользователь",Истина));   

		ИзменитьРеквизиты(ДобавляемыеРеквизиты);
		
		НовоеПоле = Элементы.Добавить("гф_ОсновнойКонтрагент",Тип("ПолеФормы"),Элементы.ГруппаНаименование);
		
		НовоеПоле.Вид			= ВидПоляФормы.ПолеВвода;
		НовоеПоле.Видимость		= Истина;
		НовоеПоле.ПутьКДанным	= "гф_ОсновнойКонтрагент";  
		
		НовоеПоле = Элементы.Добавить("гф_Логистика",Тип("ПолеФормы"),Элементы.ГруппаОтношения);
		
		НовоеПоле.Вид			= ВидПоляФормы.ПолеФлажка;
		НовоеПоле.Видимость		= Истина;
		НовоеПоле.ПутьКДанным	= "гф_Логистика";  
		
		НовоеПоле = Элементы.Добавить("гф_Зарегистрирован",Тип("ПолеФормы"),Элементы.ГруппаОтношения);
		
		НовоеПоле.Вид			= ВидПоляФормы.ПолеФлажка;
		НовоеПоле.Видимость		= Истина;
		НовоеПоле.ПутьКДанным	= "гф_Зарегистрирован";  
		
		НовоеПоле = Элементы.Добавить("гф_RC_GLN_номер",Тип("ПолеФормы"),Элементы.ГруппаИдентификация);
		
		НовоеПоле.Вид			= ВидПоляФормы.ПолеВвода;
		НовоеПоле.Видимость		= Истина;
		НовоеПоле.ПутьКДанным	= "гф_RC_GLN_номер";  
		
		НовоеПоле = Элементы.Добавить("гф_Комментарий",Тип("ПолеФормы"),ЭтаФорма);
		
		НовоеПоле.Вид			= ВидПоляФормы.ПолеВвода;
		НовоеПоле.Видимость		= Истина;
		НовоеПоле.ПутьКДанным	= "гф_Комментарий";  
		
		НовоеПоле = Элементы.Добавить("гф_АдресаДоставки",Тип("ТаблицаФормы"),Элементы.ГруппаКонтактнаяИнформация);
		
		НовоеПоле.Видимость				= Истина;
		НовоеПоле.ПутьКДанным			= "гф_АдресаДоставки";
		НовоеПоле.Отображение			= ОтображениеТаблицы.Список;  
		НовоеПоле.ПоложениеЗаголовка	= ПоложениеЗаголовкаЭлементаФормы.Лево;
		
		НовоеПоле = Элементы.Добавить("гф_АдресаДоставки_Адрес",Тип("ПолеФормы"),Элементы.гф_АдресаДоставки);
		
		НовоеПоле.Вид			= ВидПоляФормы.ПолеВвода;
		НовоеПоле.Видимость		= Истина;
		НовоеПоле.ПутьКДанным	= "гф_АдресаДоставки.Адрес";  
		
		НоваяСвязь = Новый СвязьПараметраВыбора("Отбор.Владелец", "гф_Контрагент");
		НовыйМассив = Новый Массив();
		НовыйМассив.Добавить(НоваяСвязь);
		НовоеПоле.СвязиПараметровВыбора	= Новый ФиксированныйМассив(НовыйМассив);

		НовоеПоле = Элементы.Добавить("гф_ОтветственныйМенеджер",Тип("ТаблицаФормы"),Элементы.ГруппаОбщаяИнформация);
		
		НовоеПоле.Видимость				= Истина;
		НовоеПоле.ПутьКДанным			= "гф_ОтветственныйМенеджер";
		НовоеПоле.Отображение			= ОтображениеТаблицы.Список;  
		НовоеПоле.ПоложениеЗаголовка	= ПоложениеЗаголовкаЭлементаФормы.Лево;
		
		НовоеПоле = Элементы.Добавить("гф_ОтветственныйМенеджер_Организация",Тип("ПолеФормы"),Элементы.гф_ОтветственныйМенеджер);
		
		НовоеПоле.Вид			= ВидПоляФормы.ПолеВвода;
		НовоеПоле.Видимость		= Истина;
		НовоеПоле.ПутьКДанным	= "гф_ОтветственныйМенеджер.Организация";  
		
		НовоеПоле = Элементы.Добавить("гф_ОтветственныйМенеджер_Пользователь",Тип("ПолеФормы"),Элементы.гф_ОтветственныйМенеджер);
		
		НовоеПоле.Вид			= ВидПоляФормы.ПолеВвода;
		НовоеПоле.Видимость		= Истина;
		НовоеПоле.ПутьКДанным	= "гф_ОтветственныйМенеджер.Пользователь";  
		
	КонецЕсли;	      
	
	Если ТекущийОбъект = Неопределено Тогда
		
		Возврат;
		
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст = "
	|ВЫБРАТЬ ПЕРВЫЕ 1
	|	Контрагенты.Ссылка					КАК гф_Контрагент,   
	|	Контрагенты.гф_Код					КАК гф_Код,   
	|	Контрагенты.гф_ОсновнойКонтрагент	КАК гф_ОсновнойКонтрагент,   
	|	Контрагенты.гф_Логистика			КАК гф_Логистика,   
	|	Контрагенты.гф_RC_GLN_номер			КАК гф_RC_GLN_номер,   
	|	Контрагенты.гф_Комментарий			КАК гф_Комментарий,   
	|	Контрагенты.гф_Зарегистрирован		КАК гф_Зарегистрирован   
	|ИЗ
	|	Справочник.Контрагенты КАК Контрагенты
	|ГДЕ
	|	Контрагенты.Партнер = &Партнер
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	АдресаДоставки.Адрес	КАК Адрес
	|ИЗ
	|	Справочник.Контрагенты.гф_АдресаДоставки КАК АдресаДоставки
	|ГДЕ
	|	АдресаДоставки.Ссылка.Партнер = &Партнер
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ОтветственныйМенеджер.Организация	КАК Организация,
	|	ОтветственныйМенеджер.Пользователь	КАК Пользователь
	|ИЗ
	|	Справочник.Контрагенты.гф_ОтветственныйМенеджер КАК ОтветственныйМенеджер
	|ГДЕ
	|	ОтветственныйМенеджер.Ссылка.Партнер = &Партнер";
	
	Запрос.УстановитьПараметр("Партнер",ТекущийОбъект.Ссылка);
	
	РезультатЗапроса = Запрос.ВыполнитьПакет();
	
	Выборка = РезультатЗапроса[0].Выбрать();

	Если Выборка.Следующий() Тогда
	
		ЗаполнитьЗначенияСвойств(ЭтаФорма, Выборка);
		
		ЭтаФорма["гф_АдресаДоставки"].Загрузить(РезультатЗапроса[1].Выгрузить());
		
		ЭтаФорма["гф_ОтветственныйМенеджер"].Загрузить(РезультатЗапроса[2].Выгрузить());
	
	КонецЕсли;
	
КонецПроцедуры// } #wortmann


	