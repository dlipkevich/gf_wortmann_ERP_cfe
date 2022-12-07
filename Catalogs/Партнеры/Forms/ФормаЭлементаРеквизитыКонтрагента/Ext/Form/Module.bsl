﻿#Область ОбработчикиСобытийФормы

// #wortmann {
// #4.2.03
// Добавляет в обработчик события вызов создания полей контрагента, устанавливает доступность группы доступа
// Галфинд Окунев 2022/07/05
// 
// Параметры:
// Отказ				- Булево
// СтандартнаяОбработка	- Булево
&НаСервере
Процедура гф_ПриСозданииНаСервереПосле(Отказ, СтандартнаяОбработка)

	Если Не Пользователи.ЭтоПолноправныйПользователь() Тогда
		
		Элементы.ГруппаДоступа.Доступность = Ложь;
		//Элементы.ГруппаДоступаЧастноеЛицо.Доступность = Ложь;
		
	КонецЕсли;	
	
	гф_СоздатьРеквизитыКонтрагента();
	
	гф_ДобавитьКомандуОткрытияФормыУстановкиГруппДоступа();
	
КонецПроцедуры// } #wortmann

// #wortmann {
// #4.2.03
// Добавляет в обработчик события вызовы создания и заполнения полей контрагента
// Галфинд Окунев 2022/07/05
// 
// Параметры:
// ТекущийОбъект - СправочникОбъект.Партнеры
&НаСервере
Процедура гф_ПриЧтенииНаСервереПеред(ТекущийОбъект)

	гф_СоздатьРеквизитыКонтрагента();
	
	гф_ЗаполнитьРеквизитыКонтрагента(ТекущийОбъект);
	
КонецПроцедуры// } #wortmann

// #wortmann {
// #4.2.03
// Добавляет на форму поля контрагента если еще не созданы
// Галфинд Окунев 2022/07/05
&НаСервере
Процедура гф_СоздатьРеквизитыКонтрагента()
	
	Если Элементы.Найти("гф_ОсновнойКонтрагент") = Неопределено Тогда
		
		ДобавляемыеРеквизиты = Новый Массив;
		
		КвалификаторыСтроки10	= Новый КвалификаторыСтроки(10);
		КвалификаторыСтроки13	= Новый КвалификаторыСтроки(13);
		КвалификаторыСтроки0	= Новый КвалификаторыСтроки(0);
		
		ОписаниеТиповСтрока10			= Новый ОписаниеТипов("Строка", , КвалификаторыСтроки10);
		ОписаниеТиповСтрока13			= Новый ОписаниеТипов("Строка", , КвалификаторыСтроки13);
		ОписаниеТиповСтрока0			= Новый ОписаниеТипов("Строка", , КвалификаторыСтроки0);
		ОписаниеТиповКонтрагенты		= Новый ОписаниеТипов("СправочникСсылка.Контрагенты");
		ОписаниеТиповБулево				= Новый ОписаниеТипов("Булево"); 
		ОписаниеТиповТаблицаЗначений	= Новый ОписаниеТипов("ТаблицаЗначений");
		ОписаниеТиповАдресаДоставки		= Новый ОписаниеТипов("СправочникСсылка.гф_АдресаДоставки");		
		ОписаниеТиповОрганизации		= Новый ОписаниеТипов("СправочникСсылка.Организации");		
		ОписаниеТиповПользователи		= Новый ОписаниеТипов("СправочникСсылка.Пользователи");		
		// #wortmann {
		// e1cib/data/Задача.ЗадачаИсполнителя?ref=811dbcee7bda45d711ed130ce78add5e
		// описание типов для реквизита гф_ОсновнойДоговорКонтрагента
		// Галфинд Домнышева 2022/08/04
 		ОписаниеТиповДоговоры 			= Новый ОписаниеТипов("СправочникСсылка.ДоговорыКонтрагентов");
		// } #wortmann
		
		// #wortmann {
		// e1cib/data/Задача.ЗадачаИсполнителя?ref=8127bcee7bda45d711ed75f2c32b218f
		// добавление нового ркувизита в ТЧ гф_ОсновнойДоговорКонтрагента на форму
		// Галфинд Домнышева 2022/12/07
 		ОписаниеТиповСтатусыОД 			= Новый ОписаниеТипов("СправочникСсылка.гф_СтатусПодписанияОсновногоДоговора");
		// } #wortmann
		
		// #wortmann {
		// #4.2.03
		// удалил заполнение неиспользуемого реквизита гф_Код
		// Журавлев Чугуев 2022/07/12
		//РеквизитФормы_гф_Код				= Новый РеквизитФормы("гф_Код", 
		//								ОписаниеТиповСтрока10, , "Код контрагента", Истина);
		// } #wortmann
		РеквизитФормы_гф_Контрагент			= Новый РеквизитФормы("гф_Контрагент", 
										ОписаниеТиповКонтрагенты, , "Контрагент", Истина);
		РеквизитФормы_гф_ОсновнойКонтрагент	= Новый РеквизитФормы("гф_ОсновнойКонтрагент", 
										ОписаниеТиповКонтрагенты, , "Основной контрагент", Истина);
		РеквизитФормы_гф_Логистика			= Новый РеквизитФормы("гф_Логистика", ОписаниеТиповБулево, , "Логистика", Истина);
		РеквизитФормы_гф_ГЛН_номер		= Новый РеквизитФормы("гф_GLN_номер", ОписаниеТиповСтрока13, , "GLN_номер", Истина);
		РеквизитФормы_гф_Комментарий		= Новый РеквизитФормы("гф_Комментарий", ОписаниеТиповСтрока0, , "Комментарий", Истина);
		РеквизитФормы_гф_Зарегистрирован	= Новый РеквизитФормы("гф_Зарегистрирован", 
										ОписаниеТиповБулево, , "Зарегистрирован", Истина);
		
		РеквизитФормы_гф_АдресаДоставки	= Новый РеквизитФормы("гф_АдресаДоставки", 
										ОписаниеТиповТаблицаЗначений, , "Адреса доставки", Истина); 
		РеквизитФормы_Адрес				= Новый РеквизитФормы("Адрес", 
										ОписаниеТиповАдресаДоставки, "гф_АдресаДоставки", "Адрес", Истина); 

		РеквизитФормы_гф_ОтветственныйМенеджер	= Новый РеквизитФормы("гф_ОтветственныйМенеджер", 
										ОписаниеТиповТаблицаЗначений, , "Ответственный менеджер", Истина); 
		РеквизитФормы_Организация				= Новый РеквизитФормы("Организация", 
										ОписаниеТиповОрганизации, "гф_ОтветственныйМенеджер", "Организация", Истина); 
		РеквизитФормы_Пользователь				= Новый РеквизитФормы("Пользователь", 
										ОписаниеТиповПользователи, "гф_ОтветственныйМенеджер", "Пользователь", Истина); 
		// #wortmann {
		// e1cib/data/Задача.ЗадачаИсполнителя?ref=811dbcee7bda45d711ed130ce78add5e
		// добавление новой ТЧ на форму
		// Галфинд Домнышева 2022/08/11
		РеквизитФормы_гф_ОсновнойДоговорКонтрагента	= Новый РеквизитФормы("гф_ОсновнойДоговорКонтрагента",
										ОписаниеТиповТаблицаЗначений, , "Основной договор контрагента", Истина);								
		РеквизитФормы_ОрганизацияДог				= Новый РеквизитФормы("Организация", 
										ОписаниеТиповОрганизации, "гф_ОсновнойДоговорКонтрагента", "Организация", Истина); 
		РеквизитФормы_ОсновнойДоговор						= Новый РеквизитФормы("ОсновнойДоговор", 
										ОписаниеТиповДоговоры, "гф_ОсновнойДоговорКонтрагента", "ОсновнойДоговор", Истина);									
		// } #wortmann
		
		// #wortmann {
		// e1cib/data/Задача.ЗадачаИсполнителя?ref=8127bcee7bda45d711ed75f2c32b218f
		// добавление нового ркувизита в ТЧ гф_ОсновнойДоговорКонтрагента на форму
		// Галфинд Домнышева 2022/12/07
		РеквизитФормы_СтатусПодписанияОсновногоДоговора		= Новый РеквизитФормы("СтатусПодписанияОсновногоДоговора", 
										ОписаниеТиповСтатусыОД, "гф_ОсновнойДоговорКонтрагента", "СтатусПодписанияОсновногоДоговора", Истина);	
		// } #wortmann
		
		// #wortmann {
		// #4.2.03
		// удалил заполнение неиспользуемого реквизита гф_Код
		// Журавлев Чугуев 2022/07/12
		//ДобавляемыеРеквизиты.Добавить(РеквизитФормы_гф_Код);
		// } #wortmann
		ДобавляемыеРеквизиты.Добавить(РеквизитФормы_гф_Контрагент);
		ДобавляемыеРеквизиты.Добавить(РеквизитФормы_гф_ОсновнойКонтрагент);
		ДобавляемыеРеквизиты.Добавить(РеквизитФормы_гф_Логистика);
		ДобавляемыеРеквизиты.Добавить(РеквизитФормы_гф_ГЛН_номер);
		ДобавляемыеРеквизиты.Добавить(РеквизитФормы_гф_Комментарий);
		ДобавляемыеРеквизиты.Добавить(РеквизитФормы_гф_Зарегистрирован);
		ДобавляемыеРеквизиты.Добавить(РеквизитФормы_гф_АдресаДоставки);
		ДобавляемыеРеквизиты.Добавить(РеквизитФормы_Адрес);
		ДобавляемыеРеквизиты.Добавить(РеквизитФормы_гф_ОтветственныйМенеджер);
		ДобавляемыеРеквизиты.Добавить(РеквизитФормы_Организация);
		ДобавляемыеРеквизиты.Добавить(РеквизитФормы_Пользователь);
		// #wortmann {
		// e1cib/data/Задача.ЗадачаИсполнителя?ref=811dbcee7bda45d711ed130ce78add5e
		// добавление нового реквизита на форму
		// Галфинд Домнышева 2022/08/11
		ДобавляемыеРеквизиты.Добавить(РеквизитФормы_гф_ОсновнойДоговорКонтрагента);
		ДобавляемыеРеквизиты.Добавить(РеквизитФормы_ОрганизацияДог);
		ДобавляемыеРеквизиты.Добавить(РеквизитФормы_ОсновнойДоговор);
		// } #wortmann
		
		// #wortmann {
		// e1cib/data/Задача.ЗадачаИсполнителя?ref=8127bcee7bda45d711ed75f2c32b218f
		// добавление нового ркувизита в ТЧ гф_ОсновнойДоговорКонтрагента на форму
		// Галфинд Домнышева 2022/12/07
		ДобавляемыеРеквизиты.Добавить(РеквизитФормы_СтатусПодписанияОсновногоДоговора);	
		// } #wortmann
		
		// #wortmann {
		// #4.2.03
		// Добавил вывод доп полей в адресах
		// Журавлев Чугуев 2022/07/12
		ОписаниеТиповСтрока15 = Новый ОписаниеТипов("Строка", , КвалификаторыСтроки13);
		
		РеквизитФормы_НомерАдреса = Новый РеквизитФормы("НомерАдреса", 
			ОписаниеТиповСтрока15, "гф_АдресаДоставки", "Номер адреса", Истина);
		РеквизитФормы_GLNНомер = Новый РеквизитФормы("GLNНомер", 
			ОписаниеТиповСтрока13, "гф_АдресаДоставки", "GLN номер", Истина);
		
		ДобавляемыеРеквизиты.Добавить(РеквизитФормы_НомерАдреса);
		ДобавляемыеРеквизиты.Добавить(РеквизитФормы_GLNНомер);
		// } #wortmann
		
		ИзменитьРеквизиты(ДобавляемыеРеквизиты);
		
		ТипПолеФормы = Тип("ПолеФормы");
		ТипТаблицаФормы	= Тип("ТаблицаФормы");
		
		НовоеПоле = Элементы.Добавить("гф_ОсновнойКонтрагент", ТипПолеФормы, Элементы.ГруппаНаименование);
		
		НовоеПоле.Вид			= ВидПоляФормы.ПолеВвода;
		НовоеПоле.Видимость		= Истина;
		НовоеПоле.ПутьКДанным	= "гф_ОсновнойКонтрагент"; 
		
		НовоеПоле = Элементы.Добавить("гф_Логистика", ТипПолеФормы, Элементы.ГруппаОтношения);
		
		НовоеПоле.Вид			= ВидПоляФормы.ПолеФлажка;
		НовоеПоле.Видимость		= Истина;
		НовоеПоле.ПутьКДанным	= "гф_Логистика"; 
		
		НовоеПоле = Элементы.Добавить("гф_Зарегистрирован", ТипПолеФормы, Элементы.ГруппаОтношения);
		
		НовоеПоле.Вид			= ВидПоляФормы.ПолеФлажка;
		НовоеПоле.Видимость		= Истина;
		НовоеПоле.ПутьКДанным	= "гф_Зарегистрирован"; 
		
		НовоеПоле = Элементы.Добавить("РеквизитФормы_гф_ГЛН_номер", ТипПолеФормы, Элементы.ГруппаИдентификация);
		
		НовоеПоле.Вид			= ВидПоляФормы.ПолеВвода;
		НовоеПоле.Видимость		= Истина;
		НовоеПоле.ПутьКДанным	= "гф_GLN_номер"; 
		
		НовоеПоле = Элементы.Добавить("гф_Комментарий", ТипПолеФормы, ЭтотОбъект);
		
		НовоеПоле.Вид			= ВидПоляФормы.ПолеВвода;
		НовоеПоле.Видимость		= Ложь; // Возможно в дальнейшем потребуется, пока не удаляем
		НовоеПоле.ПутьКДанным	= "гф_Комментарий";
		
		НоваяКоманда = ЭтотОбъект.Команды.Добавить("гф_ДобавитьАдрес");
		НоваяКоманда.Действие = "гф_ДобавитьАдрес";
		НоваяКоманда.Заголовок = "Добавить адрес";
		
		НоваяКнопка = Элементы.Добавить("гф_ДобавитьАдрес", Тип("КнопкаФормы"), Элементы.ГруппаКонтактнаяИнформация);
		НоваяКнопка.ИмяКоманды = "гф_ДобавитьАдрес";
		// Галфинд \ Shtak  2022/10/24  =>
		ЕстьПравоДобавленияАдреса = ПравоДоступа("Добавление", Метаданные.Справочники.гф_АдресаДоставки);
		НоваяКнопка.Доступность = ЕстьПравоДобавленияАдреса;
		// Галфинд \ Shtak  2022/10/24 <=

		НовоеПоле = Элементы.Добавить("гф_АдресаДоставки", ТипТаблицаФормы, Элементы.ГруппаКонтактнаяИнформация);
		
		НовоеПоле.Видимость					= Истина;
		НовоеПоле.ПутьКДанным				= "гф_АдресаДоставки";
		НовоеПоле.Отображение				= ОтображениеТаблицы.Список; 
		НовоеПоле.ПоложениеЗаголовка		= ПоложениеЗаголовкаЭлементаФормы.Лево;
		НовоеПоле.КоманднаяПанель.Видимость = Ложь;
		НовоеПоле.ВариантУправленияВысотой	= ВариантУправленияВысотойТаблицы.ПоСодержимому;
		НовоеПоле.УстановитьДействие("Выбор", "гф_АдресаДоставкиВыбор");
		
		НовоеПоле = Элементы.Добавить("гф_АдресаДоставки_Адрес", ТипПолеФормы, 
										Элементы.гф_АдресаДоставки);
		
		НовоеПоле.Вид			= ВидПоляФормы.ПолеВвода;
		НовоеПоле.Видимость		= Истина;
		НовоеПоле.ПутьКДанным	= "гф_АдресаДоставки.Адрес";
		НоваяСвязь = Новый СвязьПараметраВыбора("Отбор.Владелец", "гф_Контрагент");
		НовыйМассив = Новый Массив();
		НовыйМассив.Добавить(НоваяСвязь);
		НовоеПоле.СвязиПараметровВыбора	= Новый ФиксированныйМассив(НовыйМассив);
		
		НовоеПоле = Элементы.Добавить("гф_АдресаДоставки_НомерАдреса", ТипПолеФормы, Элементы.гф_АдресаДоставки);
		
		НовоеПоле.Вид			= ВидПоляФормы.ПолеВвода;
		НовоеПоле.Видимость		= Истина;
		НовоеПоле.ПутьКДанным	= "гф_АдресаДоставки.НомерАдреса";
		
		НовоеПоле = Элементы.Добавить("гф_АдресаДоставки_GLNНомер", ТипПолеФормы, Элементы.гф_АдресаДоставки);
		
		НовоеПоле.Вид			= ВидПоляФормы.ПолеВвода;
		НовоеПоле.Видимость		= Истина;
		НовоеПоле.ПутьКДанным	= "гф_АдресаДоставки.GLNНомер";
				
		НовоеПоле = Элементы.Добавить("гф_ОтветственныйМенеджер", ТипТаблицаФормы, Элементы.ГруппаДоступ);
		
		НовоеПоле.Видимость					= Истина;
		НовоеПоле.ПутьКДанным				= "гф_ОтветственныйМенеджер";
		НовоеПоле.Отображение				= ОтображениеТаблицы.Список; 
		НовоеПоле.ПоложениеЗаголовка		= ПоложениеЗаголовкаЭлементаФормы.Верх;
		НовоеПоле.ВариантУправленияВысотой	= ВариантУправленияВысотойТаблицы.ПоСодержимому;
		
		Элементы.Переместить(НовоеПоле, Элементы.ГруппаДоступ, Элементы.ГруппаДоступа);										
		
		НовоеПоле = Элементы.Добавить("гф_ОтветственныйМенеджер_Организация", ТипПолеФормы, 
										Элементы.гф_ОтветственныйМенеджер);
										
		НовоеПоле.Вид			= ВидПоляФормы.ПолеВвода;
		НовоеПоле.Видимость		= Истина;
		НовоеПоле.ПутьКДанным	= "гф_ОтветственныйМенеджер.Организация"; 
		
		НовоеПоле = Элементы.Добавить("гф_ОтветственныйМенеджер_Пользователь", ТипПолеФормы, 
										Элементы.гф_ОтветственныйМенеджер);
		
		НовоеПоле.Вид			= ВидПоляФормы.ПолеВвода;
		НовоеПоле.Видимость		= Истина;
		НовоеПоле.ПутьКДанным	= "гф_ОтветственныйМенеджер.Пользователь"; 
		
		Элементы.Переместить(Элементы.ГруппаПервичныйИнтерес, Элементы.ГруппаРодительБизнесРегион);
		Элементы.Переместить(Элементы.ГруппаСтраницыСписокЗапретовОтгрузки, Элементы.ГруппаРодительБизнесРегион);
		Элементы.Переместить(Элементы.ГруппаЦенообразование, Элементы.ГруппаРодительБизнесРегион);
		
		Элементы.ГруппаСтраницы.Высота = 43; 
		Элементы.ГруппаСтраницы.РастягиватьПоВертикали = Ложь;
		
		Для Каждого Страница Из Элементы.ГруппаСтраницы.ПодчиненныеЭлементы Цикл
			
			Страница.ВертикальнаяПрокруткаПриСжатии = Истина;
			
		КонецЦикла;	
		
		// #wortmann {
		// e1cib/data/Задача.ЗадачаИсполнителя?ref=811dbcee7bda45d711ed130ce78add5e
		// добавление новой ТЧ на форму с отбором по партнеру
		// Галфинд Домнышева 2022/08/11
		НовоеПоле = Элементы.Добавить("гф_ОсновнойДоговорКонтрагента", ТипТаблицаФормы, Элементы.ГруппаДоступ);
		
		НовоеПоле.Видимость					= Истина;
		НовоеПоле.ПутьКДанным				= "гф_ОсновнойДоговорКонтрагента";
		НовоеПоле.Отображение				= ОтображениеТаблицы.Список; 
		НовоеПоле.ПоложениеЗаголовка		= ПоложениеЗаголовкаЭлементаФормы.Верх;
		НовоеПоле.ВариантУправленияВысотой	= ВариантУправленияВысотойТаблицы.ПоСодержимому;
		
		НовоеПоле = Элементы.Добавить("гф_ОсновнойДоговорКонтрагента_Организация", ТипПолеФормы, 
										Элементы.гф_ОсновнойДоговорКонтрагента);
										
		НовоеПоле.Вид			= ВидПоляФормы.ПолеВвода;
		НовоеПоле.Видимость		= Истина;
		НовоеПоле.ПутьКДанным	= "гф_ОсновнойДоговорКонтрагента.Организация";
		НовоеПоле.УстановитьДействие("ОбработкаВыбора", "гф_ОсновнойДоговорКонтрагента_ОрганизацияОбработкаВыбора");
		
		НовоеПоле = Элементы.Добавить("гф_ОсновнойДоговорКонтрагента_ОсновнойДоговор", ТипПолеФормы, 
										Элементы.гф_ОсновнойДоговорКонтрагента);
		
		НовоеПоле.Вид			= ВидПоляФормы.ПолеВвода;
		НовоеПоле.Видимость		= Истина;
		НовоеПоле.ПутьКДанным	= "гф_ОсновнойДоговорКонтрагента.ОсновнойДоговор"; 
		
		// #wortmann {
		// e1cib/data/Задача.ЗадачаИсполнителя?ref=8127bcee7bda45d711ed75f2c32b218f
		// добавление нового ркувизита в ТЧ гф_ОсновнойДоговорКонтрагента на форму
		// Галфинд Домнышева 2022/12/07
		НовоеПоле = Элементы.Добавить("гф_ОсновнойДоговорКонтрагента_СтатусПодписанияОсновногоДоговора", ТипПолеФормы, 
										Элементы.гф_ОсновнойДоговорКонтрагента);
		
		НовоеПоле.Вид			= ВидПоляФормы.ПолеВвода;
		НовоеПоле.Видимость		= Истина;
		НовоеПоле.ПутьКДанным	= "гф_ОсновнойДоговорКонтрагента.СтатусПодписанияОсновногоДоговора";
		// } #wortmann
		
		НоваяСвязь = Новый СвязьПараметраВыбора("Отбор.Партнер", "Объект.Ссылка");
		НовыйМассив = Новый Массив();
		НовыйМассив.Добавить(НоваяСвязь); 
		// #wortmann {
		// e1cib/data/Задача.ЗадачаИсполнителя?ref=811dbcee7bda45d711ed130ce78add5e
		// добавление отбора по организации в список выбора ОсновногоДоговора
		// Галфинд Домнышева 2022/08/23
		НоваяСвязь = Новый СвязьПараметраВыбора("Отбор.Организация",
					"Элементы.гф_ОсновнойДоговорКонтрагента.ТекущиеДанные.Организация");
		НовыйМассив.Добавить(НоваяСвязь);
		// } #wortmann
		Элементы.гф_ОсновнойДоговорКонтрагента_ОсновнойДоговор.СвязиПараметровВыбора = Новый ФиксированныйМассив(НовыйМассив);
		// } #wortmann
	КонецЕсли;	 
	
КонецПроцедуры// } #wortmann

// #wortmann {
// #3.2.01
// Обработчик кнопки добавления нового адреса
// Журавлев Чугуев 2022/07/15
// 
// Параметры:
// Команда - Команда формы
&НаКлиенте
Процедура гф_ДобавитьАдрес(Команда)
	
	ДобавитьАдресЗавершение = Новый ОписаниеОповещения("ДобавитьАдресЗавершение", 
		ЭтотОбъект);
	
	ЗначенияЗаполнения = Новый Структура;
	ЗначенияЗаполнения.Вставить("Владелец", ЭтотОбъект["гф_Контрагент"]);
	
	ПараметрыАдреса = Новый Структура("ЗначенияЗаполнения", ЗначенияЗаполнения);
	
	ОткрытьФорму("Справочник.гф_АдресаДоставки.ФормаОбъекта", ПараметрыАдреса, 
		ЭтаФорма, ЭтаФорма.УникальныйИдентификатор, , , ДобавитьАдресЗавершение);
	
КонецПроцедуры// } #wortmann

// #wortmann {
// #3.2.01
// Оповещение о завершении работы с подчиненной формой
// Журавлев Чугуев 2022/07/15
// 
// Параметры:
// РезультатЗакрытия - результат открытия формы
// ДополнительныеПараметры - структура
Процедура ДобавитьАдресЗавершение(РезультатЗакрытия, ДополнительныеПараметры) Экспорт
	гф_ЗаполнитьРеквизитыКонтрагента(Объект.Ссылка);
КонецПроцедуры// } #wortmann

// #wortmann {
// #4.2.03
// Заполняет поля из справочника контрагенты в форме
// Галфинд Окунев 2022/07/07
// 
// Параметры:
// Партнер - СправочникОбъект.Партнеры - Параметр ТекущийОбъект обработчика ПриЧтенииНаСервере
&НаСервере
Процедура гф_ЗаполнитьРеквизитыКонтрагента(Партнер)
	
	Запрос = Новый Запрос; 
	
	Запрос.Текст = "ВЫБРАТЬ РАЗРЕШЕННЫЕ ПЕРВЫЕ 1
	 |	Контрагенты.Ссылка КАК Ссылка
	 |ПОМЕСТИТЬ ВТ_Контрагенты
	 |ИЗ
	 |	Справочник.Контрагенты КАК Контрагенты
	 |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Партнеры КАК Партнеры
	 |		ПО Контрагенты.Партнер = Партнеры.Ссылка
	 |			И (Партнеры.Ссылка = &Партнер)
	 |;
	 |
	 |////////////////////////////////////////////////////////////////////////////////
	 |ВЫБРАТЬ РАЗРЕШЕННЫЕ 
	 |	Контрагенты.Ссылка КАК гф_Контрагент, 
	 // #wortmann {
	 // #4.2.03
	 // удалил заполнение неиспользуемого реквизита гф_Код
	 // Журавлев Чугуев 2022/07/12
	 //|	Контрагенты.гф_Код КАК гф_Код, 
	 // } #wortmann
	 |	Контрагенты.гф_ОсновнойКонтрагент КАК гф_ОсновнойКонтрагент, 
	 |	Контрагенты.гф_Логистика КАК гф_Логистика, 
	 |	Контрагенты.гф_GLN_номер КАК гф_GLN_номер, 
	 |	Контрагенты.гф_Комментарий КАК гф_Комментарий, 
	 |	Контрагенты.гф_Зарегистрирован КАК гф_Зарегистрирован
	 |ИЗ
	 |	ВТ_Контрагенты КАК ВТ_Контрагенты
	 |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Контрагенты КАК Контрагенты
	 |		ПО ВТ_Контрагенты.Ссылка = Контрагенты.Ссылка
	 |;
	 |
	 |////////////////////////////////////////////////////////////////////////////////
	 // #wortmann {
	 // #4.2.03
	 // Адреса получим из отдельного справочника, вместо ТЧ из контрагентов
	 // Журавлев Чугуев 2022/07/12
	 //|ВЫБРАТЬ
	 //|	АдресаДоставки.Адрес КАК Адрес
	 //|ИЗ 
	 //|	Справочник.Контрагенты.гф_АдресаДоставки КАК АдресаДоставки
	 //|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВТ_Контрагенты КАК ВТ_Контрагенты
	 //|		ПО АдресаДоставки.Ссылка = ВТ_Контрагенты.Ссылка
	 |ВЫБРАТЬ РАЗРЕШЕННЫЕ 
	 |	АдресаДоставки.Ссылка КАК Адрес, 
	 |	АдресаДоставки.НомерАдреса КАК НомерАдреса, 
	 |	АдресаДоставки.GLNНомер КАК GLNНомер
	 |ИЗ
	 |	Справочник.гф_АдресаДоставки КАК АдресаДоставки
	 |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВТ_Контрагенты КАК ВТ_Контрагенты
	 |		ПО АдресаДоставки.Владелец = ВТ_Контрагенты.Ссылка
	 // } #wortmann
	 |;
	 |
	 |////////////////////////////////////////////////////////////////////////////////
	 |ВЫБРАТЬ РАЗРЕШЕННЫЕ 
	 |	ОтветственныйМенеджер.Организация КАК Организация, 
	 |	ОтветственныйМенеджер.Пользователь КАК Пользователь
	 |ИЗ
	 |	Справочник.Контрагенты.гф_ОтветственныйМенеджер КАК ОтветственныйМенеджер
	 |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВТ_Контрагенты КАК ВТ_Контрагенты
	 |		ПО ОтветственныйМенеджер.Ссылка = ВТ_Контрагенты.Ссылка
	 // #wortmann {
	 // e1cib/data/Задача.ЗадачаИсполнителя?ref=811dbcee7bda45d711ed130ce78add5e
	 // добавлено заполнение новой ТЧ
	 // Галфинд Домнышева 2022/08/11
	 |;
	 |
	 |////////////////////////////////////////////////////////////////////////////////
	 |ВЫБРАТЬ РАЗРЕШЕННЫЕ 
	 |	ОсновнойДоговорКонтрагента.Организация КАК Организация, 
	 |	ОсновнойДоговорКонтрагента.ОсновнойДоговор КАК ОсновнойДоговор,
	 // #wortmann {
	 // e1cib/data/Задача.ЗадачаИсполнителя?ref=8127bcee7bda45d711ed75f2c32b218f
	 // добавление нового ркувизита в ТЧ гф_ОсновнойДоговорКонтрагента на форму
	 // Галфинд Домнышева 2022/12/07
	 |	ОсновнойДоговорКонтрагента.СтатусПодписанияОсновногоДоговора КАК СтатусПодписанияОсновногоДоговора
	 // } #wortmann
	 |ИЗ
	 |	Справочник.Контрагенты.гф_ОсновнойДоговорКонтрагента КАК ОсновнойДоговорКонтрагента
	 |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВТ_Контрагенты КАК ВТ_Контрагенты
	 |		ПО ОсновнойДоговорКонтрагента.Ссылка = ВТ_Контрагенты.Ссылка";
	 // } #wortmann
	Запрос.УстановитьПараметр("Партнер", Партнер.Ссылка);
	
	РезультатЗапроса = Запрос.ВыполнитьПакет();
	
	Выборка = РезультатЗапроса[1].Выбрать();

	Если Выборка.Следующий() Тогда
	
		ЗаполнитьЗначенияСвойств(ЭтотОбъект, Выборка);
		
		ЭтотОбъект["гф_АдресаДоставки"].Загрузить(РезультатЗапроса[2].Выгрузить());
		ЭтотОбъект["гф_ОтветственныйМенеджер"].Загрузить(РезультатЗапроса[3].Выгрузить());
	    // #wortmann {
		// e1cib/data/Задача.ЗадачаИсполнителя?ref=811dbcee7bda45d711ed130ce78add5e
		// добавлено заполнение новой ТЧ
		// Галфинд Домнышева 2022/08/11
		ЭтотОбъект["гф_ОсновнойДоговорКонтрагента"].Загрузить(РезультатЗапроса[4].Выгрузить());
		// } #wortmann
	КонецЕсли;
	
КонецПроцедуры// } #wortmann

// #wortmann {
// #4.2.03
// Добавляет кнопку открытия формы установки групп доступа
// Галфинд Окунев 2022/07/08
&НаСервере
Процедура гф_ДобавитьКомандуОткрытияФормыУстановкиГруппДоступа()
	
	Если Не Пользователи.РолиДоступны("гф_УстановкаГруппДоступа") Тогда
		
		Возврат;
		
	КонецЕсли;
	
	Команда = Команды.Добавить("гф_ОткрытьУстановкиГруппДоступа");
	
	Команда.Заголовок = "Установка групп доступа";
	Команда.Действие = "гф_ОткрытьУстановкиГруппДоступа";
	
	КнопкаФормы = Элементы.Добавить("КнопкаПоказатьПредупреждение", 	Тип("КнопкаФормы"), 	Элементы.ГруппаДоступ);
		
	КнопкаФормы.ИмяКоманды	= "гф_ОткрытьУстановкиГруппДоступа";
	КнопкаФормы.Вид			= ВидКнопкиФормы.ОбычнаяКнопка; 
	
	Элементы.Переместить(КнопкаФормы, Элементы.ГруппаДоступ, Элементы.БизнесРегион);
	
КонецПроцедуры// } #wortmann

// #wortmann {
// #4.2.03
// Открывает форму установки групп доступа
// Галфинд Окунев 2022/07/08
// Параметры:
// Команда - Имя команды
&НаКлиенте
Процедура гф_ОткрытьУстановкиГруппДоступа(Команда) 
	
	ПараметрыОткрытия = Новый Структура;
	
	ПараметрыОткрытия.Вставить("ГруппаДоступаПартнера", Объект.ГруппаДоступа);
	
	ОткрытьФорму("ОбщаяФорма.гф_УстановкаГруппДоступа", ПараметрыОткрытия);
	
КонецПроцедуры// } #wortmann

#КонецОбласти 

#Область ОбработчикиСобытийЭлементовШапкиФормы

// #wortmann {
// e1cib/data/Задача.ЗадачаИсполнителя?ref=811dbcee7bda45d711ed130ce78add5e
// добавление новой ТЧ на форму с отбором по партнеру
// Галфинд Домнышева 2022/08/11
//
// Параметры:
//  Элемент - ФормаКлиентскогоПриложения  - элемент для обработки выбора.
//  ВыбранноеЗначение - Произвольный - см. описание параметра ВыбранноеЗначение события ОбработкаВыбора.
//  СтандартнаяОбработка - Булево - В данный параметр передается признак выполнения системной обработки события.
//
&НаКлиенте
Процедура гф_ОсновнойДоговорКонтрагента_ОрганизацияОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
    
    Отбор = Новый Структура("Организация", ВыбранноеЗначение);
    
    Если гф_ОсновнойДоговорКонтрагента.НайтиСтроки(Отбор).Количество() <> 0 Тогда
        СтандартнаяОбработка = Ложь;
        ПоказатьПредупреждение(, "Организация" + ВыбранноеЗначение + " уже присутствует в табличной части!");
    КонецЕсли; 
    
КонецПроцедуры// } #wortmann
	
#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыгф_АдресаДоставки

&НаКлиенте
Процедура гф_АдресаДоставкиВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	Если Элемент.ТекущиеДанные <> Неопределено Тогда
		ПоказатьЗначение(, Элемент.ТекущиеДанные.Адрес);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти
